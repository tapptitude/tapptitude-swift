//
//  ParallelOperation.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 07/12/2016.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

open class ParallelDataFeed: DataFeed<Any> {
    fileprivate var parallelOperation: ParallelOperations!
    
    open override func reloadOperationWithCallback(_ callback: @escaping TTCallback<Any>) -> TTCancellable? {
        return parallelOperation.execute(callback)
    }
    
    open override var canLoadMore: Bool {
        return false
    }
    
    override init () {
        self.parallelOperation = ParallelOperations()
    }
    
    public func addOperation<T>(_ isOptional: Bool = false, load: @escaping (_ callback: @escaping TTCallback<T>) -> TTCancellable?) {
        parallelOperation?.add(operation: load)
    }
    
    public func addOperation<T>(_ isOptional: Bool = false, load: @escaping (_ callback: @escaping (_ content: T?, _ error: Error?) -> ()) -> TTCancellable?) {
        parallelOperation!.add(operation: load)
    }
}


extension DataSource where Element: Any {
    fileprivate var parallelOperation: ParallelOperations? {
        get { return info["ParallelOperation"] as? ParallelOperations }
        set { info["ParallelOperation"] = parallelOperation }
    }
    
    public func addOperation<T>(_ isOptional: Bool = false, load: @escaping (_ callback: @escaping TTCallback<T>) -> TTCancellable?) {
        if self.feed == nil {
            let feed = ParallelDataFeed()
            feed.addOperation(load: load)
            self.feed = feed
        } else if let feed = self.feed as? ParallelDataFeed {
            feed.addOperation(load: load)
        } else {
            assert(false, "Only ParallelDataFeed supports more parallel operations")
        }
    }
    
    public func addOperation<T>(_ isOptional: Bool = false, load: @escaping (_ callback: @escaping (_ content: T?, _ error: Error?) -> ()) -> TTCancellable?) {
        if self.feed == nil {
            let feed = ParallelDataFeed()
            feed.addOperation(load: load)
            self.feed = feed
        } else if let feed = self.feed as? ParallelDataFeed {
            feed.addOperation(load: load)
        } else {
            assert(false, "Only ParallelDataFeed supports more parallel operations")
        }
    }
}








open class ParallelOperations {
    typealias Operation<T> = (_ callback: @escaping (_ content: [T]?, _ error: Error?, _ isOptional: Bool) -> ()) -> TTCancellable?
    private var toRunOperations: [Operation<Any>] = []
    
    public func add<T>(_ isOptional: Bool = false, operation: @escaping (_ callback: @escaping TTCallback<T>) -> TTCancellable?) {
        toRunOperations.append({ (newCallback) -> TTCancellable? in
            return operation({ (content, error) in
                newCallback(content?.map{ $0 as Any}, error, isOptional)
            })
        })
    }
    
    public func add<T>(_ isOptional: Bool = false, operation: @escaping (_ callback: @escaping (_ content: T?, _ error: Error?) -> ()) -> TTCancellable?) {
        toRunOperations.append { (newCallback) -> TTCancellable? in
            return operation({ (content, error) in
                let newContent = content != nil ? [content! as Any] : nil
                newCallback(newContent, error, isOptional)
            })
        }
    }
    
    @discardableResult
    public func execute(_ callback: @escaping TTCallback<Any>) -> TTCancellable? {
        let runningOperation = RunningOperation()
        runningOperation.completion = callback
        
        var index = 0
        for task in toRunOperations {
            let position = index
            let operation = task({[unowned runningOperation] (content, error, isOptional) in
                if isOptional, let error = error {
                    runningOperation.imediateFail(error: error)
                } else {
                    runningOperation.addResponse((content, error, position))
                }
            })
            runningOperation.operations.append(operation!)
            index += 1
        }
        
        return runningOperation
    }
}

fileprivate class RunningOperation: TTCancellable {
    typealias Response<T> = (content: [T]?, error: Error?, position: Int)
    
    var operations: [TTCancellable?] = []
    var responses: [Response<Any>] = []
    
    var completion: TTCallback<Any>!
    
    deinit {
        cancel()
    }
    
    func checkIfCompleted() {
        guard !isCancelled else {
            return
        }
        if operations.filter({ $0 != nil }).isEmpty {
            complete()
        }
    }
    
    func complete() {
        var allContent: [Any] = []
        let sorted = responses.sorted(by: { $0.position < $1.position })
        for item in sorted {
            allContent.append(contentsOf: item.content ?? [])
        }
        let error = responses.filter{ $0.error != nil }.first?.error
        
        completion(allContent, error)
    }
    
    func addResponse(_ response: Response<Any>) {
        responses.append((response.content, response.error, response.position))
        operations[response.position] = nil
        checkIfCompleted()
    }
    
    func imediateFail(error: Error) {
        cancel()
        completion(nil, error)
    }
    
    public func cancel() {
        operations.forEach { $0?.cancel() }
        operations = []
        isCancelled = true
    }
    var isCancelled = false
}
