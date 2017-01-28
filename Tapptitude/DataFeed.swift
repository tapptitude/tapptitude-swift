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

/// used by data feed
public typealias TTCallback<T> = (_ content: [T]?, _ error: Error?) -> ()

/// used by paginated data feed
/// - parameter nextOffset : is given by backend
public typealias TTCallbackNextOffset<T, OffsetType> = (_ content: [T]?, _ nextOffset: OffsetType?, _ error: Error?) -> ()



open class DataFeed<T>: TTDataFeed {
    open weak var delegate: TTDataFeedDelegate?
    
    open func reloadOperation(_ callback: @escaping TTCallback<T>) -> TTCancellable? {
        return nil
    }
    
    open func loadMoreOperation(_ callback: @escaping TTCallback<T>) -> TTCancellable? {
        return nil
    }
    
    internal var executingReload: (operation: TTCancellable?, operationID: String)?
    internal var executingLoadMore: (operation: TTCancellable?, operationID: String)?
    
    deinit {
        executingReload?.operation?.cancel()
        executingLoadMore?.operation?.cancel()
    }
    
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
            isReloading = true
            cancelLoadMore()
            
            
            executingReload?.operation?.cancel()
            executingReload = nil
            
            let operationID = UUID().uuidString
            executingReload = (operation: nil, operationID: operationID)
            let operation = reloadOperation({ [weak self] (content, error) in
                let sameOperation = operationID == self?.executingReload?.operationID
                if !sameOperation {
                    return
                }
                
                self?.executingReload = nil
                
                if let error = error {
                    self?.delegate?.dataFeed(self, failedWithError: error)
                } else {
                    self?.lastReloadDate = Date()
                    let castedContent = content?.map { $0 as Any }
                    self?.delegate?.dataFeed(self, didReloadContent: castedContent )
                }
                
                self?.isReloading = false
            })
            
            executingReload = (operation: operation, operationID: operationID)
        }
    }
    open func cancelReload() {
        if isReloading {
            executingReload?.operation?.cancel()
            executingReload = nil
            
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
            
            executingLoadMore?.operation?.cancel()
            executingLoadMore = nil
            
            let operationID = UUID().uuidString
            executingLoadMore = (operation: nil, operationID: operationID)
            let operation = loadMoreOperation({[weak self] (content, error) in
                let sameOperation = operationID == self?.executingLoadMore?.operationID
                if !sameOperation {
                    return
                }
                
                self?.executingLoadMore = nil
                
                if let error = error {
                    self?.delegate?.dataFeed(self, failedWithError: error)
                } else {
                    let castedContent = content?.map { $0 as Any }
                    self?.delegate?.dataFeed(self, didLoadMoreContent: castedContent)
                }
                
                self?.isLoadingMore = false
            })
            
            executingLoadMore = (operation: operation, operationID: operationID)
        }
    }
    open func cancelLoadMore() {
        if isLoadingMore {
            executingLoadMore?.operation?.cancel()
            executingLoadMore = nil
            
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
    
    /// store/access any information here by using a unique key
    open var info: [String: Any] = [:]
}
