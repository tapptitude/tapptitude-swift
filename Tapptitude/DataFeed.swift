//
//  DataFeed.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

/// allow an operation to be canceled at any time
public protocol TTCancellable: class {
    func cancel()
}

/// DataFeed expected closure callback
public typealias TTCallback<T> = (_ result: Result<T>) -> ()

public typealias TTLoadOperation<T> = (_ callback: @escaping TTCallback<[T]>) -> TTCancellable?
/// used by paginated data feed
/// - parameter nextOffset : is given by backend
public typealias TTLoadPageOperation<T, OffsetType> = (_ offset: OffsetType?, _ callback: @escaping TTCallback<([T], OffsetType?)>) -> TTCancellable?


open class DataFeed<T, OffsetType>: TTDataFeed {
    
    open weak var delegate: TTDataFeedDelegate?
    
    fileprivate var executingOperation: RunningOperation?
    
    deinit {
        executingOperation?.cancel()
    }
    
    open var state: FeedState = .idle {
        didSet {
            delegate?.dataFeed(self, stateChangedFrom: oldValue, toState: state)
        }
    }
    
    public init(loadPage: @escaping TTLoadPageOperation<T, OffsetType>) {
        self.loadPageOperation = loadPage
    }
    
    public convenience init (load: @escaping (_ callback: @escaping TTCallback<[T]>) -> TTCancellable?) {
        self.init(loadPage: {(offset, callback) in
            return load({ result in
                let offsetResult: Result<([T], OffsetType?)> = result.map { ($0, nil) }
                callback(offsetResult)
            })
        })
    }
    
    /// nextOffset == nil --> reload operation, else load more operation
    open var nextOffset: OffsetType? // dependends on backend API
    open var loadPageOperation: TTLoadPageOperation<T, OffsetType>! // next
    
    //Mark: re-update content
    open var enableReloadAfterXSeconds = 5 * 60.0
    open var lastReloadDate : Date?
    open func shouldReload() -> Bool {
        let shouldReload = canReload && (lastReloadDate == nil || (lastReloadDate!.timeIntervalSinceNow > enableReloadAfterXSeconds))
        return shouldReload
    }
    
    //MARK: Reload -
    open var canReload: Bool {
        return !isReloading
    }
    
    /// Will cancel any loadMore operation if any, or will do nothing if canReload is false
    open func reload() {
        if canReload {
            print("Reloading content...")
            cancelLoadMore()
            state = .reloading
            hasMorePages = false
            executeOperation()
        }
    }
    open func cancelReload() {
        if isReloading {
            executingOperation?.cancel()
            executingOperation = nil
            
            self.state = .idle
        }
    }
    var didReloadContent: Bool {
        return (lastReloadDate != nil)
    }
    open var hasMorePages: Bool = false
    
    //MARK: Load More -
    open var canLoadMore: Bool {
        return !isReloading && !isLoadingMore && didReloadContent && hasMorePages
    }
    open func loadMore() {
        if canLoadMore {
            print("Loading more content...")
            state = .loadingMore
            executeOperation()
        }
    }
    
    open func cancelLoadMore() {
        if isLoadingMore {
            executingOperation?.cancel()
            executingOperation = nil
            
            self.state = .idle
        }
    }
    
    func executeOperation() {
        let runningOperation = RunningOperation()
        executingOperation?.cancel()
        executingOperation = runningOperation
        
        let offset = isReloading ? nil : nextOffset
        let operation = loadPageOperation(offset, {[weak self] result in
            let sameOperation = runningOperation === self?.executingOperation
            if !sameOperation {
                return
            }
            
            self?.executingOperation = nil
            
            let state = self!.state.loadState!
            let result = self?.transform?(result, state) ?? result.map{ ($0.0.map{$0 as Any}, $0.1) }
            
            switch result {
            case .success(_):
                self?.nextOffset = result.value?.1
                self?.hasMorePages = (self?.nextOffset != nil)
                
                if self?.state == .reloading {
                    self?.lastReloadDate = Date()
                }
            case .failure(_):
                break
            }
            
            let newResult = result.map{ $0.0 }
            self?.delegate?.dataFeed(self, didLoadResult: newResult, forState: state)
            self?.state = .idle
        })
        
        runningOperation.operation = operation
    }
    
    /// store/access any information here by using a unique key
    open var info: [String: Any] = [:]
    
    open var transform: ((_ result: Result<([T], OffsetType?)>, _ state: FeedState.Load) -> Result<([Any], OffsetType?)>)?
    
    open func setTransform<V>(_ transform: @escaping (_ content: [T], _ offset: OffsetType?, _ state: FeedState.Load) -> [V]) {
        self.transform = { result, state in
            let ourResult: Result<[V]> = result.map{ transform($0, $1, state) }
            let anyResult = ourResult.map(as: Any.self)
            return result.map{( anyResult.value!, $1 )}
        }
    }
}


public class SimpleFeed<T>: DataFeed<T, Void> {
    public init (load: @escaping (_ callback: @escaping TTCallback<[T]>) -> TTCancellable?) {
        super.init(loadPage: {(offset, callback) in
            return load({ result in
                callback(result.map { ($0, nil) })
            })
        })
    }
}


fileprivate class RunningOperation: TTCancellable {
    var operation: TTCancellable?
    
    func cancel() {
        operation?.cancel()
    }
}






public extension DataFeed where OffsetType: BinaryInteger {

    convenience public init(pageSize: OffsetType,
                            enableLoadMoreOnlyForCompletePage: Bool = true,
                            loadPage: @escaping (_ offset:OffsetType, _ pageSize:Int, _ callback: @escaping TTCallback<[T]>) -> TTCancellable?) {
        self.init { (offset, callback) -> TTCancellable? in
            let pageSize = pageSize as! Int
            return loadPage(offset ?? 0, pageSize, { result in
                let contentCount = result.value?.count ?? 0
                let loadMore = enableLoadMoreOnlyForCompletePage ? (contentCount == pageSize) : (contentCount > 0)
                let nextOffset: OffsetType? = loadMore ? ((offset ?? 0) + (pageSize as! OffsetType)) : nil

                let newResult = result.map{ ($0, nextOffset) }
                callback(newResult)
            })
        }
    }
}








extension DataSource {
    public convenience init(feed: TTDataFeed) {
        self.init()
        self.feed = feed
        self.feed?.delegate = self
    }
    
    public convenience init <T>(load: @escaping (_ callback: @escaping TTCallback<[T]>) -> TTCancellable?) {
        self.init()
        feed = SimpleFeed(load: load)
        feed?.delegate = self
    }
    
    public convenience init<T, OffsetType>(loadPage: @escaping (_ offset: OffsetType?, _ callback: @escaping TTCallback<([T], OffsetType?)>) -> TTCancellable?) {
        self.init()
        self.feed = DataFeed(loadPage: loadPage)
        self.feed?.delegate = self // need to set otherwise is null in init
    }

    public convenience init<T>(pageSize:Int, loadPage: @escaping (_ offset:Int, _ pageSize:Int, _ callback: @escaping TTCallback<[T]>) -> TTCancellable?) {
        self.init()
        self.feed = DataFeed(pageSize: pageSize, loadPage: loadPage)
        self.feed?.delegate = self // need to set otherwise is null in init
    }
}







extension DataSource {
    public var loadOperation: TTLoadOperation<T> {
        get { fatalError() }
        set { self.feed = DataFeed<T, Void>(load: newValue) }
    }
    
    public var loadPageOperation: TTLoadPageOperation<T,String> {
        get { fatalError() }
        set { self.feed = DataFeed<T, String>(loadPage: newValue) }
    }
    
    public func setLoadPage<Offset>(operation: @escaping TTLoadPageOperation<T,Offset>) {
        self.feed = DataFeed<T, Offset>(loadPage: operation)
    }
    
    public func setLoadPage<V, Offset>(operation: @escaping TTLoadPageOperation<V,Offset>) {
        self.feed = DataFeed<V, Offset>(loadPage: operation)
    }
    
    public func loadOperation<V>(_ operation: @escaping TTLoadOperation<V>, transform: @escaping (_ content: [V]) -> [T]) {
        let feed = DataFeed<V, Void>(load: operation)
        feed.setTransform { (content, _, _) -> [T] in
            return transform(content)
        }
        self.feed = feed
    }
    
    public func setLoadPage<V, Offset>(_ operation: @escaping TTLoadPageOperation<V,Offset>, transform: @escaping (_ content: [V], _ offset: Offset?, _ state: FeedState.Load) -> [T]) {
        let feed = DataFeed<V, Offset>(loadPage: operation)
        feed.setTransform(transform)
        self.feed = feed
    }
    
    public func setFeed<V, Offset>(_ feed: DataFeed<V, Offset>, transform: @escaping (_ content: [V], _ offset: Offset?, _ state: FeedState.Load) -> [T]) {
        feed.setTransform(transform)
        self.feed = feed
    }
}
