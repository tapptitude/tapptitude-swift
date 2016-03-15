//
//  SimpleDataFeed.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

class SimpleDataFeed <T> : DataFeed <T> {
    
    private var loadOperation: (TTCallback<T>.Signature) -> TTCancellable?
    
    init (load: (callback: TTCallback<T>.Signature) -> TTCancellable?) {
        self.loadOperation = load
        super.init()
    }
    
    override func reloadOperationWithCallback(callback: TTCallback<T>.Signature) -> TTCancellable? {
        return loadOperation(callback)
    }
    
    override var canLoadMore: Bool {
        return false
    }
}

extension DataSource {
    convenience init <T>(load: (callback: TTCallback<T>.Signature) -> TTCancellable?) {
        self.init()
        feed = SimpleDataFeed(load: load)
        feed?.delegate = self
    }
}