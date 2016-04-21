//
//  SimpleDataFeed.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public class SimpleDataFeed <T> : DataFeed <T> {
    
    private var loadOperation: (TTCallback<T>.Signature) -> TTCancellable?
    
    public init (load: (callback: TTCallback<T>.Signature) -> TTCancellable?) {
        self.loadOperation = load
        super.init()
    }
    
    public override func reloadOperationWithCallback(callback: TTCallback<T>.Signature) -> TTCancellable? {
        return loadOperation(callback)
    }
    
    public override var canLoadMore: Bool {
        return false
    }
}

extension DataSource {
    public convenience init <T>(load: (callback: TTCallback<T>.Signature) -> TTCancellable?) {
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