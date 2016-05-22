//
//  FeedController.swift
//  TestTapptitude
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit
import Tapptitude

extension NSURLSessionTask: TTCancellable {
    
}


class FeedController: CollectionFeedController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "test")
        
        addPullToRefresh()
        forceTouchPreviewEnabled = true
        animatedUpdates = true
        
//        self.dataSource = DataSource(content: ["arra"])
        let cellController = TextCellController()
        cellController.didSelectContent = { _, indexPath, collectionView in
            let dataSource = self.dataSource as? TTDataSourceMutable
            dataSource?.replaceAtIndexPath(indexPath, newElement: "Ghita")
        }
        
        let numberCellController = CollectionCellController<Int, UICollectionViewCell>(cellSize: CGSize(width: 100, height: 50))
        numberCellController.configureCell = { cell, content, indexPath in
            cell.backgroundColor = UIColor.blueColor()
        }
        
        self.cellController = MultiCollectionCellController([cellController, numberCellController])
        
//        let dataSource = DataSource (load: { (callback: TTCallback<String>.Signature) -> TTCancellable? in
//            return APIMock(callback: { (content, error) in
//                var newContent : [String]? = content
//                newContent?.append("2312")
//                callback(content: newContent, error: error)
//            })
//        })
        
//        let dataSource = DataSource { APIMock(callback: $0) }
        
        let dataSource = DataSource(pageSize: 10, loadPage: { (offset, limit, callback) -> TTCancellable? in
            return APIMock(callback: callback)
        })
        
//        let items = NSArray(arrayLiteral: "Why Algorithms as Microservices are Changing Software Development\n We recently wrote about how the Algorithm Economy and containers have created a fundamental shift in software development. Today, we want to look at the 10 ways algorithms as microservices change the way we build and deploy software.", 123)
//        let dataSource = DataSource(items)
//        dataSource.feed = PaginatedDataFeed(loadPage: { (offset, limit, callback) -> TTCancellable? in
//            return APIPaginatedMock(offset: offset, limit: limit, callback: callback)
//        })
        
//        let url = NSURL(string: "https://httpbin.org/get")
//        var url_request = NSMutableURLRequest(URL: url!)
//        
//        dataSource.feed = SimpleDataFeed<String> { (callback) -> TTCancellable? in
//            let task = NSURLSession.sharedSession().dataTaskWithRequest(url_request) { data , response , error  in
//                let stringResponse = data != nil ? String(data: data!, encoding: NSUTF8StringEncoding) : nil
//                let items: [String]? = stringResponse != nil ? [stringResponse!] : nil
//                print(error)
//                
//                dispatch_async(dispatch_get_main_queue()) {
//                    callback(content: items, error: error)
//                }
//            }
//            task.resume()
//            
//            return task
//        }
        
//        dataSource.feed = PaginatedOffsetDataFeed<String, String>(loadPage: { (offset, callback) -> TTCancellable? in
//            let alex = 3
//            return APIPaginateOffsetdMock(offset: offset, limit: 10, callback: callback)
//        })
        
//        let dataSource = DataSource { (offset:String?, callback: TTCallbackNextOffset<String, String>.Signature) -> TTCancellable? in
//            return APIPaginateOffsetdMock(offset: offset, limit: 10, callback: callback)
//        }
        self.dataSource = dataSource
        
        animatedUpdates = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
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
