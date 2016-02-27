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
    var callback: (content: [String]?, error: NSError?)->Void
    
    init(callback: (content: [String]?, error: NSError?)->Void) {
        self.callback = callback
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            print("test")
            if !self.wasCancelled {
                callback(content: ["234"], error: nil)
            }
        }
    }
}


class APIPaginatedMock: TTCancellable {
    func cancel() {
        wasCancelled = true
    }
    
    var wasCancelled = false
    var callback: (content: [AnyObject]?, error: NSError?)->Void
    
    init(offset:Int, limit:Int, callback: (content: [AnyObject]?, error: NSError?)->Void) {
        self.callback = callback
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            print("test")
            if !self.wasCancelled {
                if offset > 3 {
                    callback(content: nil, error: nil)
                } else {
                    callback(content: ["234"], error: nil)
                }
            }
        }
    }
}


class APIPaginateOffsetdMock: TTCancellable {
    func cancel() {
        wasCancelled = true
    }
    
    var wasCancelled = false
    var callback: (content: [AnyObject]?, nextOffset:AnyObject?, error: NSError?)->Void
    
    init(offset:String?, limit:Int, callback: (content: [AnyObject]?, nextOffset:AnyObject?, error: NSError?)->Void) {
        self.callback = callback
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            print("test")
            if !self.wasCancelled {
                if offset == nil {
                    callback(content: nil, nextOffset: "1", error: nil)
                } else if offset == "1" {
                    callback(content: [""], nextOffset: "2", error: nil)
                } else if offset == "2" {
                    callback(content: [""], nextOffset: "3", error: nil)
                } else if offset == "3" {
                    callback(content: nil, nextOffset: "4", error: nil)
                } else if offset == "4" {
                    callback(content: [""], nextOffset: "5", error: nil)
                } else if offset == "5" {
                    callback(content: [""], nextOffset: nil, error: nil)
                }
            }
        }
    }
}

class FeedController: CollectionFeedController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "test")
        
        addPullToRefresh()
//        self.dataSource = DataSource(content: ["arra"])
        let cellController = CollectionCellController<String, UICollectionViewCell>(cellSize: CGSize(width: 100, height: 100))
        cellController.configureCell = { cell, content, indexPath in
            cell.backgroundColor = UIColor.redColor()
            print(cell)
        }
        cellController.didSelectContent = { _, _, _ in
            let controller = CollectionFeedController()
            print(controller.view)
            print(controller.collectionView)
            self.showViewController(controller, sender: nil)
        }
        cellController.minimumInteritemSpacing = 20
        cellController.minimumLineSpacing = 10
        self.cellController = cellController
        
        let dataSource = DataSource()
        
//        dataSource.feed = SimpleDataFeed(){ (callback) -> TTCancellable? in
//            return APIMock(callback: { (content, error) in
//                var newContent = content
//                newContent?.append("2312")
//                callback(content: newContent, error: error)
//            })
//        }
        
//        dataSource.feed = PaginatedDataFeed(loadPage: { (offset, limit, callback) -> TTCancellable? in
//            return APIPaginatedMock(offset: offset, limit: limit, callback: callback)
//        })
        
        dataSource.feed = PaginatedOffsetDataFeed(loadPage: { (offset, limit, callback) -> TTCancellable? in
            let newOffset = offset as? String
            return APIPaginateOffsetdMock(offset: newOffset, limit: limit, callback: callback)
        })
        
//        self.dataSource = DataSource(content:["23"])
        self.dataSource = dataSource
        animatedUpdates = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size: CGSize = dataSource!.hasContent() == true ? CGSizeMake(0, 30) : CGSizeZero
        return size
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header: UICollectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "test", forIndexPath: indexPath);
            header.backgroundColor = UIColor.darkGrayColor();
            return header;
        } else {
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
        }
    }
}