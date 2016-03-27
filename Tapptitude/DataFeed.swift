//
//  DataFeed.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public protocol TTCancellable {
    func cancel()
}

public enum TTCallback <T> {
    public typealias Signature = (content: [T]?, error: NSError?) -> Void
}

public enum TTCallbackNextOffset <T, OffsetType> {
    public typealias Signature = (content: [T]?, nextOffset: OffsetType?, error: NSError?) -> Void // next offset is given by backend
}

public class DataFeed<T>: TTDataFeed {
    public weak var delegate: TTDataFeedDelegate?
    
    public func reloadOperationWithCallback(callback: TTCallback<T>.Signature) -> TTCancellable? {
        return nil
    }
    
    public func loadMoreOperationWithCallback(callback: TTCallback<T>.Signature) -> TTCancellable? {
        return nil
    }
    
    internal var executingReloadOperation: TTCancellable?;
    internal var executingLoadMoreOperation: TTCancellable?;
    
    //Mark: re-update content
    public var enableReloadAfterXSeconds = 5 * 60.0
    public var lastReloadDate : NSDate?
    public func shouldReload() -> Bool {
        let shouldReload = canReload && (lastReloadDate == nil || (lastReloadDate?.timeIntervalSinceNow > enableReloadAfterXSeconds))
        return shouldReload
    }
    
    //MARK: Reload -
    public var canReload: Bool {
        return !isReloading
    }
    public func reload() {
        if canReload {
            print("Reloading content...")
            isReloading = true
            
            if isLoadingMore {
                cancelLoadMore()
            }
            
            executingReloadOperation?.cancel()
            executingReloadOperation = reloadOperationWithCallback({ [unowned self] (content, error) in
                self.executingReloadOperation = nil
                
                if let error = error {
                    self.delegate?.dataFeed(self, failedWithError: error)
                } else {
                    self.lastReloadDate = NSDate()
                    let castedContent = content?.map { $0 as Any }
                    self.delegate?.dataFeed(self, didReloadContent: castedContent )
                }
                
                self.isReloading = false
            })
        }
    }
    public func cancelReload() {
        if isReloading {
            executingReloadOperation?.cancel()
            executingReloadOperation = nil
            
            isReloading = false
        }
    }
    var didReloadContent: Bool {
        return (lastReloadDate != nil)
    }
    
    
    //MARK: Load More -
    public var canLoadMore: Bool {
        return !isReloading && !isLoadingMore && didReloadContent
    }
    public func loadMore() {
        if canLoadMore {
            print("Loading more content...")
            isLoadingMore = true
            
            executingLoadMoreOperation?.cancel()
            executingLoadMoreOperation = loadMoreOperationWithCallback({[unowned self] (content, error) in
                self.executingLoadMoreOperation = nil
                
                if let error = error {
                    self.delegate?.dataFeed(self, failedWithError: error)
                } else {
                    let castedContent = content?.map { $0 as Any }
                    self.delegate?.dataFeed(self, didLoadMoreContent: castedContent)
                }
                
                self.isLoadingMore = false
            })
        }
    }
    public func cancelLoadMore() {
        if isLoadingMore {
            executingLoadMoreOperation?.cancel()
            executingLoadMoreOperation = nil
            
            isLoadingMore = false
        }
    }
    
    public var isReloading: Bool = false {
        didSet {
            delegate?.dataFeed(self, isReloading: isReloading)
        }
    }
    public var isLoadingMore: Bool = false {
        didSet {
            delegate?.dataFeed(self, isLoadingMore: isLoadingMore)
        }
    }
}
