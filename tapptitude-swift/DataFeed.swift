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

public typealias TTCallback = (content: [AnyObject]?, error: NSError?)->Void
public typealias TTNextOffsetCallback = (content: [AnyObject]?, nextOffset: AnyObject?, error: NSError?)->Void // next offset is given by backend

public class DataFeed: NSObject, TTDataFeed {
    override init() {
        super.init()
    }
    
    public var delegate: TTDataFeedDelegate?
    
    public func reloadOperationWithCallback(callback: TTCallback) -> TTCancellable? {
        return nil
    }
    
    public func loadMoreOperationWithCallback(callback: TTCallback) -> TTCancellable? {
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
    public dynamic var canReload: Bool {
        return !isReloading
    }
    public func reload() {
        if canReload {
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
                    self.delegate?.dataFeed(self, didReloadContent: content)
                }
                
                self.isReloading = false
            })
            
            isReloading = true
        }
    }
    public func cancelReload() {
        if (isReloading) {
            executingReloadOperation?.cancel()
            executingReloadOperation = nil
            
            isReloading = false
        }
    }
    
    
    //MARK: Load More -
    public dynamic var canLoadMore: Bool {
        return !isReloading && !isLoadingMore
    }
    public func loadMore() {
        if canLoadMore {
            executingLoadMoreOperation?.cancel()
            executingLoadMoreOperation = loadMoreOperationWithCallback({[unowned self] (content, error) in
                self.executingLoadMoreOperation = nil
                
                if let error = error {
                    self.delegate?.dataFeed(self, failedWithError: error)
                } else {
                    self.delegate?.dataFeed(self, didLoadMoreContent: content)
                }
                
                self.isLoadingMore = false
            })
            
            isLoadingMore = true
        }
    }
    public func cancelLoadMore() {
        if (isLoadingMore) {
            executingLoadMoreOperation?.cancel()
            executingLoadMoreOperation = nil
            
            isLoadingMore = false
        }
    }
    
    public dynamic var isReloading: Bool = false
    public dynamic var isLoadingMore: Bool = false
    
    public override class func keyPathsForValuesAffectingValueForKey(key: String) -> Set<String> {
        var keyPaths = super.keyPathsForValuesAffectingValueForKey(key)
        if key == "canLoadMore" {
            keyPaths = Set(["isReloading", "isLoadingMore"]).union(keyPaths)
        } else if key == "canReload" {
            keyPaths = Set(["isReloading"]).union(keyPaths)
        }
        return keyPaths;
    }
}
