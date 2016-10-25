//
//  DataFeed.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public protocol TTCancellable {
    func cancel()
}

public enum TTCallback <T> {
    public typealias Signature = (_ content: [T]?, _ error: NSError?) -> ()
}

public enum TTCallbackNextOffset <T, OffsetType> {
    public typealias Signature = (_ content: [T]?, _ nextOffset: OffsetType?, _ error: NSError?) -> () // next offset is given by backend
}

open class DataFeed<T>: TTDataFeed {
    open weak var delegate: TTDataFeedDelegate?
    
    open func reloadOperationWithCallback(_ callback: @escaping TTCallback<T>.Signature) -> TTCancellable? {
        return nil
    }
    
    open func loadMoreOperationWithCallback(_ callback: @escaping TTCallback<T>.Signature) -> TTCancellable? {
        return nil
    }
    
    internal var executingReloadOperation: TTCancellable?;
    internal var executingLoadMoreOperation: TTCancellable?;
    
    deinit {
        executingReloadOperation?.cancel()
        executingLoadMoreOperation?.cancel()
    }
    
    //Mark: re-update content
    open var enableReloadAfterXSeconds = 5 * 60.0
    open var lastReloadDate : Date?
    open func shouldReload() -> Bool {
        let shouldReload = canReload && (lastReloadDate == nil || (lastReloadDate?.timeIntervalSinceNow > enableReloadAfterXSeconds))
        return shouldReload
    }
    
    //MARK: Reload -
    open var canReload: Bool {
        return !isReloading
    }
    open func reload() {
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
                    self.lastReloadDate = Date()
                    let castedContent = content?.map { $0 as Any }
                    self.delegate?.dataFeed(self, didReloadContent: castedContent )
                }
                
                self.isReloading = false
            })
        }
    }
    open func cancelReload() {
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
    open var canLoadMore: Bool {
        return !isReloading && !isLoadingMore && didReloadContent
    }
    open func loadMore() {
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
    open func cancelLoadMore() {
        if isLoadingMore {
            executingLoadMoreOperation?.cancel()
            executingLoadMoreOperation = nil
            
            isLoadingMore = false
        }
    }
    
    open var isReloading: Bool = false {
        didSet {
            delegate?.dataFeed(self, isReloading: isReloading)
        }
    }
    open var isLoadingMore: Bool = false {
        didSet {
            delegate?.dataFeed(self, isLoadingMore: isLoadingMore)
        }
    }
}
