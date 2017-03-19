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
            delegate?.dataFeed(self, fromState: oldValue, toState: state)
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
            
            let newResult = result.map{ $0.0.map{$0 as Any} }
            self?.delegate?.dataFeed(self, didLoadResult: newResult, forState: self!.state)
            self?.state = .idle
        })
        
        runningOperation.operation = operation
    }
    
    /// store/access any information here by using a unique key
    open var info: [String: Any] = [:]
}

extension DataFeed {
    
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


public extension DataFeed where OffsetType: Integer {

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
    public convenience init<T: TTDataFeed>(feed: T) {
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
//    public var loadOperation: ((_ callback: @escaping TTCallback<T>) -> TTCancellable?)? {
//        get {
//            if let feed = self.feed as? SimpleDataFeed<T> {
//                return feed.loadOperation
//            }
//            return nil
//        }
//        set {
//            if let function = newValue {
//                self.feed = SimpleDataFeed(load: function)
//                feed?.delegate = self
//            } else {
//                self.feed = nil
//            }
//        }
//    }
}
