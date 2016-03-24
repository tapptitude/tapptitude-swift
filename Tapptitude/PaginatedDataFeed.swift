//
//  PaginatedDataFeed.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public class PaginatedDataFeed<T>: DataFeed<T> {
    public var limit: Int = 1
    public var offset: Int = 0 // maybe a NSNumber or NSString, dependend on backend API
    
    private var loadPageOperation: (offset:Int, limit:Int, callback:TTCallback<T>.Signature) -> TTCancellable? // load page using integer offset
//    private var loadPageNextOffsetOperation: (TTCallback) -> TTCancellable? // next page offset is given by backend
    
    public var enableLoadMoreOnlyForCompletePage = true
    
    init(loadPage: (offset:Int, limit:Int, callback:TTCallback<T>.Signature) -> TTCancellable?) {
        self.loadPageOperation = loadPage
    }
    
    override public var canLoadMore: Bool {
        return hasMorePages && super.canLoadMore
    }
    
    public override func reloadOperationWithCallback(callback: TTCallback<T>.Signature) -> TTCancellable? {
        return loadPageOperation(offset: 0, limit: limit) {[unowned self] content, error in
            if error == nil {
                self.offset = self.limit
                self.hasMorePages = self.enableLoadMoreOnlyForCompletePage ? (content?.count == self.limit) : (content?.count > 0)
            }
            
            callback(content:content, error:error)
        }
    }
    
    public override func loadMoreOperationWithCallback(callback: TTCallback<T>.Signature) -> TTCancellable? {
        return loadPageOperation(offset: offset, limit: limit) {[unowned self] content, error in
            if error == nil {
                self.offset += self.limit
                self.hasMorePages = self.enableLoadMoreOnlyForCompletePage ? (content?.count == self.limit) : (content?.count > 0)
            }
            
            callback(content:content, error:error)
        }
    }
    
    
    public var hasMorePages: Bool = false
}

extension DataSource {
    convenience init<T>(pageSize:Int, loadPage: (offset:Int, limit:Int, callback:TTCallback<T>.Signature) -> TTCancellable?) {
        self.init()
        let feed = PaginatedDataFeed(loadPage: loadPage)
        feed.limit = pageSize
        feed.delegate = self
        self.feed = feed
    }
}


public class PaginatedOffsetDataFeed<T, OffsetType> : DataFeed<T> {
    
    public var limit: Int = 10
    public var offset: OffsetType? // dependends on backend API
    
    private var loadPageNextOffsetOperation: (offset: OffsetType?, limit:Int, callback: TTCallbackNextOffset<T, OffsetType>.Signature) -> TTCancellable? // next page offset is given by backend
    
    init(loadPage: (offset:OffsetType?, limit:Int, callback:TTCallbackNextOffset<T, OffsetType>.Signature) -> TTCancellable?) {
        self.loadPageNextOffsetOperation = loadPage
    }
    
    override public var canLoadMore: Bool {
        return hasMorePages && super.canLoadMore
    }
    
    public override func reloadOperationWithCallback(callback: TTCallback<T>.Signature) -> TTCancellable? {
        return loadPageNextOffsetOperation(offset: nil, limit: limit) {[unowned self] content, nextOffset, error in
            if error == nil {
                self.offset = nextOffset
                self.hasMorePages = (nextOffset != nil)
            }
            
            callback(content:content, error:error)
        }
    }
    
    public override func loadMoreOperationWithCallback(callback: TTCallback<T>.Signature) -> TTCancellable? {
        return loadPageNextOffsetOperation(offset: offset, limit: limit) {[unowned self] content, nextOffset, error in
            if error == nil {
                self.offset = nextOffset
                self.hasMorePages = (nextOffset != nil)
            }
            
            callback(content:content, error:error)
        }
    }
    
    
    public var hasMorePages: Bool = false
}