//
//  FeedController.swift
//  TestTapptitude
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

class APIMock: TTCancellable {
    func cancel() {
        wasCancelled = true
    }
    
    var wasCancelled = false
    var callback: (content: [AnyObject]?, error: NSError?)->Void
    
    init(callback: (content: [AnyObject]?, error: NSError?)->Void) {
        self.callback = callback
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            print("test")
            if !self.wasCancelled {
                callback(content: nil, error: nil)
            }
        }
    }
}

class FeedController: CollectionFeedController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.dataSource = DataSource(content: ["arra"])
        let cellController = CollectionCellController<String, UICollectionViewCell>(cellSize: CGSize(width: 50, height: 50))
        cellController.configureCellBlock = { cell, content, indexPath in
            cell.backgroundColor = UIColor.redColor()
            print(cell)
        }
        cellController.didSelectContentBlock = { _, _, _ in
            let controller = CollectionFeedController()
            print(controller.view)
            print(controller.collectionView)
            self.showViewController(controller, sender: nil)
        }
        self.cellController = cellController
        
        let dataSource = DataSource(content: [])
        dataSource.feed = SimpleDataFeed(loadOperation: { (callback: (content: [AnyObject]?, error: NSError?) -> Void) -> TTCancellable? in
            return APIMock(callback: callback)
        })
        
        
        self.dataSource = dataSource
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
}