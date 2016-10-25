//
//  SimpleDataFeed.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

open class SimpleDataFeed <T> : DataFeed <T> {
    
    fileprivate var loadOperation: (@escaping TTCallback<T>.Signature) -> TTCancellable?
    
    public init (load: @escaping (_ callback: @escaping TTCallback<T>.Signature) -> TTCancellable?) {
        self.loadOperation = load
        super.init()
    }
    
    open override func reloadOperationWithCallback(_ callback: @escaping TTCallback<T>.Signature) -> TTCancellable? {
        return loadOperation(callback)
    }
    
    open override var canLoadMore: Bool {
        return false
    }
}

extension DataSource {
    public convenience init <T>(load: @escaping (_ callback: TTCallback<T>.Signature) -> TTCancellable?) {
        self.init()
        feed = SimpleDataFeed(load: load)
        feed?.delegate = self
    }
    
    public convenience init<T: TTDataFeed>(feed: T) {
        self.init()
        self.feed = feed
        self.feed?.delegate = self
    }
}
