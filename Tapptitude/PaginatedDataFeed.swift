//
//  PaginatedDataFeed.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public class PaginatedDataFeed<ContentType, OffsetType> : DataFeed<ContentType> {
    public var offset: OffsetType? // dependends on backend API
    
    private var loadPageNextOffsetOperation: (offset: OffsetType?, callback: TTCallbackNextOffset<ContentType, OffsetType>.Signature) -> TTCancellable? // next page offset is given by backend
    
    public init(loadPage: (offset: OffsetType?, callback: TTCallbackNextOffset<ContentType, OffsetType>.Signature) -> TTCancellable?) {
        self.loadPageNextOffsetOperation = loadPage
    }
    
    override public var canLoadMore: Bool {
        return hasMorePages && super.canLoadMore
    }
    
    public override func reloadOperationWithCallback(callback: TTCallback<ContentType>.Signature) -> TTCancellable? {
        return loadNextPage(nil, callback: callback)
    }
    
    public override func loadMoreOperationWithCallback(callback: TTCallback<ContentType>.Signature) -> TTCancellable? {
        return loadNextPage(offset, callback: callback)
    }
    
    internal func loadNextPage(offset: OffsetType?, callback: TTCallback<ContentType>.Signature) -> TTCancellable? {
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

public extension PaginatedDataFeed where OffsetType: IntegerType {
    
    convenience public init(pageSize: OffsetType, enableLoadMoreOnlyForCompletePage: Bool = true,
                            loadPage: (offset:OffsetType, pageSize:Int, callback:TTCallback<ContentType>.Signature) -> TTCancellable?) {
        self.init { (offset, callback) -> TTCancellable? in
            let pageSize = pageSize as! Int
            return loadPage(offset: offset ?? 0, pageSize: pageSize, callback: { (content, error) in
                let loadMore = enableLoadMoreOnlyForCompletePage ? (content?.count == pageSize) : (content?.count > 0)
                let nextOffset: OffsetType? = loadMore ? ((offset ?? 0) + (pageSize as! OffsetType)) : nil
                
                callback(content: content, nextOffset: nextOffset, error: error)
            })
        }
    }
}

extension DataSource {
    public convenience init<T, OffsetType>(loadPage: (offset: OffsetType?, callback:TTCallbackNextOffset<T, OffsetType>.Signature) -> TTCancellable?) {
        self.init()
        self.feed = PaginatedDataFeed(loadPage: loadPage)
        self.feed?.delegate = self // need to set otherwise is null in init
    }
    
    public convenience init<T>(pageSize:Int, loadPage: (offset:Int, pageSize:Int, callback:TTCallback<T>.Signature) -> TTCancellable?) {
        self.init()
        self.feed = PaginatedDataFeed(pageSize: pageSize, loadPage: loadPage)
        self.feed?.delegate = self // need to set otherwise is null in init
    }
}
