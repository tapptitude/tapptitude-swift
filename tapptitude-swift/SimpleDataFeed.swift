//
//  SimpleDataFeed.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

class SimpleDataFeed : DataFeed {
    
    private var loadOperation: (TTCallback) -> TTCancellable?
    
    init (load: (callback:TTCallback)-> TTCancellable?) {
        self.loadOperation = load
        super.init()
    }
    
    override func reloadOperationWithCallback(callback: TTCallback) -> TTCancellable? {
        return loadOperation(callback)
    }
    
    override var canLoadMore: Bool {
        return false
    }
}

extension DataSource {
    convenience init (load: (callback:TTCallback)-> TTCancellable?) {
        self.init()
        feed = SimpleDataFeed(load: load)
        feed?.delegate = self
    }
}