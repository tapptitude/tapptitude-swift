//
//  DataFeedProtocol.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public enum FeedState {
    case idle
    case reloading
    case loadingMore
}

public protocol TTDataFeed: class {
    
    weak var delegate: TTDataFeedDelegate? { get set }
    
    func shouldReload() -> Bool
    
    var canReload: Bool { get }
    func reload()
    func cancelReload()
    
    var canLoadMore: Bool { get }
    func loadMore()
    func cancelLoadMore()
    
    var lastReloadDate : Date? {get}
    var state: FeedState { get }
}

extension TTDataFeed {
    var isReloading: Bool {
        return state == .reloading
    }
    var isLoadingMore: Bool {
        return state == .loadingMore
    }
    
    var canReload: Bool {
        return !isReloading
    }
}

public protocol TTDataFeedDelegate: class {    
    func dataFeed(_ dataFeed: TTDataFeed?, fromState: FeedState, toState: FeedState)
    func dataFeed(_ dataFeed: TTDataFeed?, didLoadResult result: Result<[Any]>, forState: FeedState)
}

//class TTAnyDataFeedDelegate<Element>: TTDataFeedDelegateAny {
//    var delegate: TTAnyDataFeedDelegateBox<Element>
//    
//    public init<T : TTDataFeedDelegateAny where T.Element == Element>(_ base: T) {
//        delegate = TTAnyDataFeedDelegateBoxHelper(base)
//    }
//    
//    public func dataFeed(_ dataFeed: TTDataFeed?, fromState: FeedState, toState: FeedState) {
//        delegate.dataFeed(dataFeed, fromState: fromState, toState: toState)
//    }
//    
//    public func dataFeed(_ dataFeed: TTDataFeed?, didLoadResult result: Result<[Element]>, forState: FeedState) {
//        delegate.dataFeed(dataFeed, didLoadResult: result, forState: forState)
//    }
//}
//
//class TTAnyDataFeedDelegateBox<Element>: TTDataFeedDelegateAny {
//    public func dataFeed(_ dataFeed: TTDataFeed?, fromState: FeedState, toState: FeedState) {
//        
//    }
//    
//    public func dataFeed(_ dataFeed: TTDataFeed?, didLoadResult result: Result<[Element]>, forState: FeedState) {
//        
//    }
//}
//
//class TTAnyDataFeedDelegateBoxHelper<T: TTDataFeedDelegateAny>: TTAnyDataFeedDelegateBox<T.Element> {
//    var delegate: T
//    
//    init(_ delegate: T) {
//        self.delegate = delegate
//    }
//    
//    override public func dataFeed(_ dataFeed: TTDataFeed?, fromState: FeedState, toState: FeedState) {
//        delegate.dataFeed(dataFeed, fromState: fromState, toState: toState)
//    }
//    
//    override public func dataFeed(_ dataFeed: TTDataFeed?, didLoadResult result: Result<[T.Element]>, forState: FeedState) {
//        delegate.dataFeed(dataFeed, didLoadResult: result, forState: forState)
//    }
//}

//class ProxyDataFeed<T>: TTDataFeedDelegate {
//    weak var delegate: TTDataFeedDelegate?
//    
//    var transform: ((Result<[Any]>) -> (Result<[Any]>))!
//    
//    init() {
//        let feed = SimpleDataFeed<String> { (callback) -> TTCancellable? in
//            return nil
//        }.
//        let dataSource = DataSource<String>(feed: feed)
//    }
//    
//    func dataFeed(_ dataFeed: TTDataFeed?, fromState: FeedState, toState: FeedState) {
//        delegate?.dataFeed(dataFeed, fromState: fromState, toState: toState)
//    }
//    
//    func dataFeed(_ dataFeed: TTDataFeed?, didLoadResult result: Result<[Any]>, forState: FeedState) {
//        let mappedResult = transform(result)
//        delegate?.dataFeed(dataFeed, didLoadResult: mappedResult, forState: forState)
//    }
//}

class ProxyDataFeed<T>: TTDataFeed {
    var feed: TTDataFeed!
    
    init (feed: TTDataFeed) {
        self.feed = feed
        feed.delegate = self
    }
    
    var transform: ((_ state: FeedState, Result<[Any]>) -> (Result<[T]>))!
    
    weak var delegate: TTDataFeedDelegate?
    
    func shouldReload() -> Bool {
        return feed.shouldReload()
    }
    var canReload: Bool {
        return feed.canReload
    }
    func reload() {
        feed.reload()
    }
    func cancelReload() {
        feed.cancelReload()
    }
    var canLoadMore: Bool {
        return feed.canLoadMore
    }
    func loadMore() {
        feed.loadMore()
    }
    func cancelLoadMore() {
        feed.cancelLoadMore()
    }
    var isReloading: Bool {
        return feed.isReloading
    }
    var isLoadingMore: Bool {
        return feed.isLoadingMore
    }
    var lastReloadDate : Date? {
        return feed.lastReloadDate
    }
    var state: FeedState {
        return feed.state
    }
}

extension ProxyDataFeed: TTDataFeedDelegate {
    func dataFeed(_ dataFeed: TTDataFeed?, fromState: FeedState, toState: FeedState) {
        delegate?.dataFeed(dataFeed, fromState: fromState, toState: toState)
    }

    func dataFeed(_ dataFeed: TTDataFeed?, didLoadResult result: Result<[Any]>, forState: FeedState) {
        let mappedResult = transform(forState, result)
        let anyResult = mappedResult.map(as: Any.self)
        delegate?.dataFeed(dataFeed, didLoadResult: anyResult, forState: forState)
    }
}

extension DataFeed {
    func transform<NewType>() -> ProxyDataFeed<NewType> {
        return ProxyDataFeed(feed: self)
    }
}
