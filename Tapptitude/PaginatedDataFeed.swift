//
//  PaginatedDataFeed.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public class PaginatedDataFeed<T, OffsetType> : DataFeed<T> {
    public var offset: OffsetType? // dependends on backend API
    
    private var loadPageNextOffsetOperation: (offset: OffsetType?, callback: TTCallbackNextOffset<T, OffsetType>.Signature) -> TTCancellable? // next page offset is given by backend
    
    public init(loadPage: (offset: OffsetType?, callback: TTCallbackNextOffset<T, OffsetType>.Signature) -> TTCancellable?) {
        self.loadPageNextOffsetOperation = loadPage
    }
    
    override public var canLoadMore: Bool {
        return hasMorePages && super.canLoadMore
    }
    
    public override func reloadOperationWithCallback(callback: TTCallback<T>.Signature) -> TTCancellable? {
        return loadNextPage(nil, callback: callback)
    }
    
    public override func loadMoreOperationWithCallback(callback: TTCallback<T>.Signature) -> TTCancellable? {
        return loadNextPage(offset, callback: callback)
    }
    
    internal func loadNextPage(offset: OffsetType?, callback: TTCallback<T>.Signature) -> TTCancellable? {
        return loadPageNextOffsetOperation(offset: offset) {[unowned self] content, nextOffset, error in
            if error == nil {
                self.offset = nextOffset
                self.hasMorePages = (nextOffset != nil)
            }
            
            callback(content:content, error:error)
        }
    }
    
    public var hasMorePages: Bool = false
}

extension DataSource {
    public convenience init<T>(pageSize:Int, loadPage: (offset:Int, limit:Int, callback:TTCallback<T>.Signature) -> TTCancellable?) {
        self.init()
        let feed = PaginatedDataFeedInt(pageSize: pageSize, loadPage: loadPage)
        self.feed = feed
    }
}

extension DataSource {
    public convenience init<T, OffsetType>(loadPage: (offset: OffsetType?, callback:TTCallbackNextOffset<T, OffsetType>.Signature) -> TTCancellable?) {
        self.init()
        self.feed = PaginatedDataFeed(loadPage: loadPage)
    }
}



//public class PaginatedDataFeedTest<T>: PaginatedDataFeed<T, Int> {
//    public init(limit: Int, loadPage: (offset:Int, limit:Int, callback:TTCallback<T>.Signature) -> TTCancellable?) {
//        
//        super.init { (offset, callback) -> TTCancellable? in
//            return loadPage(offset: offset ?? 0, limit: limit, callback: { (content, error) in
//                let enableLoadMoreOnlyForCompletePage = true
//                let loadMore = enableLoadMoreOnlyForCompletePage ? (content?.count == limit) : (content?.count > 0)
//                let nextOffset = loadMore ? (offset ?? 0 + limit) : nil
//                
//                callback(content: content, nextOffset: nextOffset, error: error)
//            })
//        }
//        
//        self.offset = 0
//    }
//}

public class PaginatedDataFeedInt<T>: DataFeed<T> {
    public var pageSize: Int!
    public var offset: Int = 0 // next offset is calculated with pageSize
    
    private var loadPageOperation: (offset:Int, limit:Int, callback:TTCallback<T>.Signature) -> TTCancellable? // load page using integer offset
    
    public var enableLoadMoreOnlyForCompletePage = true
    
    public init(pageSize: Int, loadPage: (offset:Int, limit:Int, callback:TTCallback<T>.Signature) -> TTCancellable?) {
        self.pageSize = pageSize
        self.loadPageOperation = loadPage
    }
    
    override public var canLoadMore: Bool {
        return hasMorePages && super.canLoadMore
    }
    
    public override func reloadOperationWithCallback(callback: TTCallback<T>.Signature) -> TTCancellable? {
        return loadNextPage(0, callback: callback)
    }
    
    public override func loadMoreOperationWithCallback(callback: TTCallback<T>.Signature) -> TTCancellable? {
        return loadNextPage(offset, callback: callback)
    }
    
    internal func loadNextPage(offset: Int, callback: TTCallback<T>.Signature) -> TTCancellable? {
        return loadPageOperation(offset: offset, limit: pageSize) {[unowned self] content, error in
            if error == nil {
                self.offset = offset + self.pageSize
                self.hasMorePages = self.enableLoadMoreOnlyForCompletePage ? (content?.count == self.pageSize) : (content?.count > 0)
            }
            
            callback(content:content, error:error)
        }
    }
    
    public var hasMorePages: Bool = false
}