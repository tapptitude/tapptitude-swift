//
//  DataFeedProtocol.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public protocol TTDataFeed {
    
    weak var delegate: TTDataFeedDelegate? { get set }
    
    func shouldReload() -> Bool
    
    var canReload: Bool { get } // should be KVO-compliant
    func reload()
    func cancelReload()
    
    var canLoadMore: Bool { get } // should be KVO-compliant
    func loadMore()
    func cancelLoadMore()
    
    var isReloading: Bool { get } // should be KVO-compliant
    var isLoadingMore: Bool { get } // should be KVO-compliant
    
    var lastReloadDate : Date? {get}
}

public protocol TTDataFeedDelegate: class {
    func dataFeed(_ dataFeed: TTDataFeed?, failedWithError error: NSError)
    
    func dataFeed(_ dataFeed: TTDataFeed?, didReloadContent content: [Any]?)
    func dataFeed(_ dataFeed: TTDataFeed?, didLoadMoreContent content: [Any]?)
    
    func dataFeed(_ dataFeed: TTDataFeed?, isReloading: Bool)
    func dataFeed(_ dataFeed: TTDataFeed?, isLoadingMore: Bool)
}
