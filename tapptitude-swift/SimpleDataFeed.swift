//
//  SimpleDataFeed.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

class SimpleDataFeed : DataFeed {
    var enableReloadAfterXSeconds = 5 * 60.0
    
    private var loadOperation : ((content: [AnyObject]?, error: NSError?)->Void) -> TTCancellable?
    
    init (loadOperation: ((content: [AnyObject]?, error: NSError?)->Void)-> TTCancellable?) {
        self.loadOperation = loadOperation
        super.init()
    }
    
    override func reloadOperationWithCallback(callback: (content: [AnyObject]?, error: NSError?) -> Void) -> TTCancellable? {
        return loadOperation(callback)
    }
    
    override var canLoadMore: Bool {
        return false
    }
    
    override func shouldReload() -> Bool {
        let shouldReload = canReload && (lastReloadDate == nil || (lastReloadDate?.timeIntervalSinceNow > enableReloadAfterXSeconds))
        return shouldReload
    }
}