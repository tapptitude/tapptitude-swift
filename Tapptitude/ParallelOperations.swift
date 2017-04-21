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
open class ParallelDataFeed: DataFeed<Any, Any> {

    open var reloadOperation: ParallelOperations! = ParallelOperations()
    open var loadMoreOperation: ParallelOperations! = ParallelOperations()
    
    public init () {
        super.init { (offset, callback) -> TTCancellable? in
            return nil
        }
        
        self.loadPageOperation = {[weak self] (offset, callback) -> TTCancellable? in
            switch self!.state {
            case .reloading:
                return self!.reloadOperation.execute(offset: offset, callback)
            case .loadingMore:
                return self!.loadMoreOperation.execute(offset: offset, callback)
            case .idle:
                abort()
            }
        }
        
    }
}
//
//
//extension DataSource where Element: Any {
//    fileprivate var parallelOperation: ParallelOperations? {
//        get { return info["ParallelOperation"] as? ParallelOperations }
//        set { info["ParallelOperation"] = parallelOperation }
//    }
//    
//    public func addOperation<T>(failOnError: Bool = true, load: @escaping (_ callback: @escaping TTCallback<T>) -> TTCancellable?) {
//        if self.feed == nil {
//            let feed = ParallelDataFeed()
//            feed.reloadOperation.append(failOnError: failOnError, operation: load)
//            self.feed = feed
//        } else if let feed = self.feed as? ParallelDataFeed {
//            feed.reloadOperation.append(failOnError: failOnError, operation: load)
//        } else {
//            assert(false, "Only ParallelDataFeed supports more parallel operations")
//        }
//    }
//    
//    public func addOperation<T>(failOnError: Bool = true, load: @escaping (_ callback: @escaping (_ content: T?, _ error: Error?) -> ()) -> TTCancellable?) {
//        if self.feed == nil {
//            let feed = ParallelDataFeed()
//            feed.reloadOperation.append(failOnError: failOnError, operation: load)
//            self.feed = feed
//        } else if let feed = self.feed as? ParallelDataFeed {
//            feed.reloadOperation.append(failOnError: failOnError, operation: load)
//        } else {
//            assert(false, "Only ParallelDataFeed supports more parallel operations")
//        }
//    }
//    
//    
//    public func addLoadMoreOperation<T, Offset>(failOnError: Bool = true, load: @escaping (_ offset: Offset?, _ callback: TTCallbackNextOffset<T, Offset>) -> TTCancellable?) {
//        if let feed = self.feed as? ParallelDataFeed {
//            feed.loadMoreOperation = ParallelOperations()
//            feed.loadMoreOperation.append(failOnError: failOnError, operation: load)
//        } else {
//            assert(false, "Only ParallelDataFeed supports more parallel operations")
//        }
//    }
//}
//
//
//
//
//
//
//
/// Construct an operation that containts multiple operations --> that will be run in parallel.
/// this operation can be treated as a single operation
/// In the end content from all operations are passed into a single array, in the order of the append
open class ParallelOperations {
    private var toRunOperations: [TTLoadPageOperation<Any, Any>] = []
    private var tofailOnErrors: [Bool] = []
    
    public func append<T>(failOnError: Bool = true, operation: @escaping TTLoadOperation<T>) {
        toRunOperations.append({ (offset, newCallback) -> TTCancellable? in
            return operation({ result in
                newCallback(result.map({ ($0, nil) }))
            })
        })
        tofailOnErrors.append(failOnError)
    }
    
    public func append<T>(failOnError: Bool = true, operation: @escaping (_ callback: @escaping (_ result: Result<T>) -> ()) -> TTCancellable?) {
        toRunOperations.append { (offset, newCallback) -> TTCancellable? in
            return operation({ (result) in
                newCallback(result.map({ ([$0], nil) }))
            })
        }
        tofailOnErrors.append(failOnError)
    }
    
    public func append<T, Offset>(failOnError: Bool = true, operation: @escaping TTLoadPageOperation<T, Offset>) {
        
        toRunOperations.append { (offset, newCallback) -> TTCancellable? in
            
            return operation(offset as? Offset, { result in
                newCallback(result.map({ ($0.map{ $0 as Any}, $1 as Any) }))
            })
        }
        tofailOnErrors.append(failOnError)
    }
    
    @discardableResult
    public func execute(offset: Any? = nil, _ callback: @escaping TTCallback<([Any], Any?)>) -> TTCancellable? {
        let runningOperation = RunningOperation()
        runningOperation.completion = callback
        
        var index = 0
        for task in toRunOperations {
            let position = index
            let failOnError = tofailOnErrors[index]
            let operation = task(offset, {[unowned runningOperation] (result) in
                if failOnError, let error = result.error {
                    runningOperation.failNow(error: error)
                } else {
                    runningOperation.addResponse((result, position))
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
    typealias Response<T, Offset> = (result: Result<([T], Offset?)>, position: Int)
    
    /// active operations
    var operations: [TTCancellable?] = []
    var responses: [Response<Any, Any>] = []
    
    var completion: TTCallback<([Any], Any?)>!
    
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
            let content = item.result.value?.0
            allContent.append(contentsOf: content ?? [])
        }
        
        let nextOffset = responses.flatMap({ $0.result.value?.1 }).first
        completion(.success( (allContent, nextOffset) ))
        
//        let error = responses.filter{ $0.error != nil }.first?.error
//        let nextOffset = responses.filter{ $0.nextOffset != nil }.first?.nextOffset
//        
//        completion(allContent, nextOffset, error)
    }
    
    func addResponse(_ response: Response<Any, Any>) {
        responses.append(response)
        operations[response.position] = nil
        checkIfCompleted()
    }
    
    func failNow(error: Error) {
        cancel()
        completion(.failure(error))
    }
    
    public func cancel() {
        operations.forEach { $0?.cancel() }
        operations = []
        isCancelled = true
    }
    var isCancelled = false
}
