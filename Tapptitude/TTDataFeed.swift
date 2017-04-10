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
    
    public enum Load {
        case reloading
        case loadingMore
    }
}

extension FeedState {
    var loadState: Load? {
        switch self {
        case .idle: return nil
        case .reloading: return Load.reloading
        case .loadingMore: return Load.loadingMore
        }
    }
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
    func dataFeed(_ dataFeed: TTDataFeed?, stateChangedFrom fromState: FeedState, toState: FeedState)
    func dataFeed(_ dataFeed: TTDataFeed?, didLoadResult result: Result<[Any]>, forState: FeedState.Load)
}
