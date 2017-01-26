//
//  SimpleDataFeed.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

open class SimpleDataFeed <T> : DataFeed <T> {
    
    internal var loadOperation: (@escaping TTCallback<T>) -> TTCancellable?
    
    public init (load: @escaping (_ callback: @escaping TTCallback<T>) -> TTCancellable?) {
        self.loadOperation = load
        super.init()
    }
    
    open override func reloadOperation(_ callback: @escaping TTCallback<T>) -> TTCancellable? {
        return loadOperation(callback)
    }
    
    open override var canLoadMore: Bool {
        return false
    }
}

extension DataSource {
    public convenience init <T>(load: @escaping (_ callback: @escaping TTCallback<T>) -> TTCancellable?) {
        self.init()
        feed = SimpleDataFeed(load: load)
        feed?.delegate = self
    }
    
    public convenience init<T: TTDataFeed>(feed: T) {
        self.init()
        self.feed = feed
        self.feed?.delegate = self
    }
    
    
    public var loadOperation: ((_ callback: @escaping TTCallback<T>) -> TTCancellable?)? {
        get {
            if let feed = self.feed as? SimpleDataFeed<T> {
                return feed.loadOperation
            }
            return nil
        }
        set {
            if let function = newValue {
                self.feed = SimpleDataFeed(load: function)
                feed?.delegate = self
            } else {
                self.feed = nil
            }
        }
    }
}
