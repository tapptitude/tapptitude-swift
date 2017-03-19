//
//  PaginatedDataFeed.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

//open class PaginatedDataFeed<ContentType, OffsetType> : DataFeed<ContentType> {
//    open var offset: OffsetType? // dependends on backend API
//    
//    fileprivate var loadPageNextOffsetOperation: (_ offset: OffsetType?, _ callback: @escaping TTCallbackNextOffset<ContentType, OffsetType>) -> TTCancellable? // next page offset is given by backend
//    
//    public init(loadPage: @escaping (_ offset: OffsetType?, _ callback: @escaping TTCallbackNextOffset<ContentType, OffsetType>) -> TTCancellable?) {
//        self.loadPageNextOffsetOperation = loadPage
//    }
//    
//    override open var canLoadMore: Bool {
//        return hasMorePages && super.canLoadMore
//    }
//    
//    open override func reloadOperation(_ callback: @escaping TTCallback<ContentType>) -> TTCancellable? {
//        return loadNextPage(nil, callback: callback)
//    }
//    
//    open override func loadMoreOperation(_ callback: @escaping TTCallback<ContentType>) -> TTCancellable? {
//        return loadNextPage(offset, callback: callback)
//    }
//    
//    internal func loadNextPage(_ offset: OffsetType?, callback: @escaping TTCallback<ContentType>) -> TTCancellable? {
//        return loadPageNextOffsetOperation(offset) {[weak self] content, nextOffset, error in
//            if error == nil {
//                self?.offset = nextOffset
//                self?.hasMorePages = (nextOffset != nil)
//            }
//            
//            callback(content, error)
//        }
//    }
//    
//    open var hasMorePages: Bool = false
//}
//
//public extension PaginatedDataFeed where OffsetType: Integer {
//    
//    convenience public init(pageSize: OffsetType, enableLoadMoreOnlyForCompletePage: Bool = true,
//                            loadPage: @escaping (_ offset:OffsetType, _ pageSize:Int, _ callback: @escaping TTCallback<ContentType>) -> TTCancellable?) {
//        self.init { (offset, callback) -> TTCancellable? in
//            let pageSize = pageSize as! Int
//            return loadPage(offset ?? 0, pageSize, { (content, error) in
//                let contentCount = content?.count ?? 0
//                let loadMore = enableLoadMoreOnlyForCompletePage ? (contentCount == pageSize) : (contentCount > 0)
//                let nextOffset: OffsetType? = loadMore ? ((offset ?? 0) + (pageSize as! OffsetType)) : nil
//                
//                callback(content, nextOffset, error)
//            })
//        }
//    }
//}
//
//extension DataSource {
//    public convenience init<T, OffsetType>(loadPage: @escaping (_ offset: OffsetType?, _ callback: @escaping TTCallbackNextOffset<T, OffsetType>) -> TTCancellable?) {
//        self.init()
//        self.feed = PaginatedDataFeed(loadPage: loadPage)
//        self.feed?.delegate = self // need to set otherwise is null in init
//    }
//    
//    public convenience init<T>(pageSize:Int, loadPage: @escaping (_ offset:Int, _ pageSize:Int, _ callback: @escaping TTCallback<T>) -> TTCancellable?) {
//        self.init()
//        self.feed = PaginatedDataFeed(pageSize: pageSize, loadPage: loadPage)
//        self.feed?.delegate = self // need to set otherwise is null in init
//    }
//}
