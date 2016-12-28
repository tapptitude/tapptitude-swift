//
//  ParallelOperation.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 07/12/2016.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

/// Allows multiple operation to be treated as a single reload operation,
/// after that a load more operation is executed when offset != nil
open class ParallelDataFeed: DataFeed<Any> {
    
    /// offset == nil --> reload operation, else load more operation
    open var offset: Any?
    
    open var reloadOperation: ParallelOperations! = ParallelOperations()
    open var loadMoreOperation: ParallelOperations! = ParallelOperations()
    
    open var hasMorePages: Bool = false
    open override var canLoadMore: Bool {
        return hasMorePages && super.canLoadMore
    }
    
    open override func reloadOperationWithCallback(_ callback: @escaping TTCallback<Any>) -> TTCancellable? {
        assert(reloadOperation.canExecute, "Please add operations to run")
        
        return reloadOperation.execute({ (content, nextOffset, error) in
            if error == nil {
                self.offset = nextOffset
                self.hasMorePages = (nextOffset != nil)
            }
            callback(content, error)
        })
    }
    
    open override func loadMoreOperationWithCallback(_ callback: @escaping TTCallback<Any>) -> TTCancellable? {
        assert(loadMoreOperation.canExecute, "Please add operations to run")
        
        return loadMoreOperation.execute(offset: self.offset, { (content, nextOffset, error) in
            if error == nil {
                self.offset = nextOffset
                self.hasMorePages = (nextOffset != nil)
            }
            callback(content, error)
        })
    }
    
    public override init () {
        
    }
}


extension DataSource where Element: Any {
    fileprivate var parallelOperation: ParallelOperations? {
        get { return info["ParallelOperation"] as? ParallelOperations }
        set { info["ParallelOperation"] = parallelOperation }
    }
    
    public func addOperation<T>(failOnError: Bool = true, load: @escaping (_ callback: @escaping TTCallback<T>) -> TTCancellable?) {
        if self.feed == nil {
            let feed = ParallelDataFeed()
            feed.reloadOperation.append(failOnError: failOnError, operation: load)
            self.feed = feed
        } else if let feed = self.feed as? ParallelDataFeed {
            feed.reloadOperation.append(failOnError: failOnError, operation: load)
        } else {
            assert(false, "Only ParallelDataFeed supports more parallel operations")
        }
    }
    
    public func addOperation<T>(failOnError: Bool = true, load: @escaping (_ callback: @escaping (_ content: T?, _ error: Error?) -> ()) -> TTCancellable?) {
        if self.feed == nil {
            let feed = ParallelDataFeed()
            feed.reloadOperation.append(failOnError: failOnError, operation: load)
            self.feed = feed
        } else if let feed = self.feed as? ParallelDataFeed {
            feed.reloadOperation.append(failOnError: failOnError, operation: load)
        } else {
            assert(false, "Only ParallelDataFeed supports more parallel operations")
        }
    }
    
    
    public func addLoadMoreOperation<T, Offset>(failOnError: Bool = true, load: @escaping (_ offset: Offset?, _ callback: TTCallbackNextOffset<T, Offset>) -> TTCancellable?) {
        if let feed = self.feed as? ParallelDataFeed {
            feed.loadMoreOperation = ParallelOperations()
            feed.loadMoreOperation.append(failOnError: failOnError, operation: load)
        } else {
            assert(false, "Only ParallelDataFeed supports more parallel operations")
        }
    }
}







/// Construct an operation that containts multiple operations --> that will be run in parallel.
/// this operation can be treated as a single operation
/// In the end content from all operations are passed into a single array, in the order of the append
open class ParallelOperations {
    typealias Operation<T, Offset> = (_ offset: Offset?, _ callback: @escaping (_ content: [T]?, _ nextOffset: Offset?, _ error: Error?, _ failOnError: Bool) -> ()) -> TTCancellable?
    private var toRunOperations: [Operation<Any, Any>] = []
    
    public func append<T>(failOnError: Bool = true, operation: @escaping (_ callback: @escaping TTCallback<T>) -> TTCancellable?) {
        toRunOperations.append({ (offset, newCallback) -> TTCancellable? in
            return operation({ (content, error) in
                newCallback(content?.map{ $0 as Any}, nil, error, failOnError)
            })
        })
    }
    
    public func append<T>(failOnError: Bool = true, operation: @escaping (_ callback: @escaping (_ content: T?, _ error: Error?) -> ()) -> TTCancellable?) {
        toRunOperations.append { (offset, newCallback) -> TTCancellable? in
            return operation({ (content, error) in
                let newContent = content != nil ? [content! as Any] : nil
                newCallback(newContent, error, nil, failOnError)
            })
        }
    }
    
    public func append<T, Offset>(failOnError: Bool = true, operation: @escaping (_ offset: Offset?, _ callback: @escaping TTCallbackNextOffset<T, Offset>) -> TTCancellable?) {
        
        toRunOperations.append { (offset, newCallback) -> TTCancellable? in
            
            return operation(offset as? Offset, { (content, nextOffset, error) in
                let newContent = content?.map{ $0 as Any}
                let newOffset = nextOffset as Any
                newCallback(newContent, newOffset, error, failOnError)
            })
        }
    }
    
    @discardableResult
    public func execute(offset: Any? = nil, _ callback: @escaping TTCallbackNextOffset<Any, Any>) -> TTCancellable? {
        let runningOperation = RunningOperation()
        runningOperation.completion = callback
        
        var index = 0
        for task in toRunOperations {
            let position = index
            let operation = task(offset, {[unowned runningOperation] (content, nextOffset, error, failOnError) in
                if failOnError, let error = error {
                    runningOperation.failNow(error: error)
                } else {
                    runningOperation.addResponse((content, nextOffset, error, position))
                }
            })
            runningOperation.operations.append(operation!)
            index += 1
        }
        
        return runningOperation
    }
    
    var canExecute: Bool {
        return toRunOperations.isEmpty == false
    }
}


/// An operation that encapsulate all running operations
/// only first error, and first offset are passed to completion
fileprivate class RunningOperation: TTCancellable {
    typealias Response<T, Offset> = (content: [T]?, nextOffset: Offset?, error: Error?, position: Int)
    
    /// active operations
    var operations: [TTCancellable?] = []
    var responses: [Response<Any, Any>] = []
    
    var completion: TTCallbackNextOffset<Any, Any>!
    
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
        let nextOffset = responses.filter{ $0.nextOffset != nil }.first?.nextOffset
        
        completion(allContent, nextOffset, error)
    }
    
    func addResponse(_ response: Response<Any, Any>) {
        responses.append((response.content, response.nextOffset, response.error, response.position))
        operations[response.position] = nil
        checkIfCompleted()
    }
    
    func failNow(error: Error) {
        cancel()
        completion(nil, nil, error)
    }
    
    public func cancel() {
        operations.forEach { $0?.cancel() }
        operations = []
        isCancelled = true
    }
    var isCancelled = false
}
