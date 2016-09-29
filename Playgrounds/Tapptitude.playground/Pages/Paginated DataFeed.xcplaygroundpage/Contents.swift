//: [Previous](@previous)

import UIKit
import Tapptitude

class TextCellController: CollectionCellController<String, TextCell> {
    init() {
        super.init(cellSize: CGSize(width: -1, height: 50))
        minimumInteritemSpacing = 20
        minimumLineSpacing = 10
        sectionInset = UIEdgeInsetsMake(0, 0, 10, 0)
    }
    
    override func configureCell(cell: TextCell, for content: String, at indexPath: NSIndexPath) {
        cell.label.text = content
    }
    
    override func cellSize(for content: String, in collectionView: UICollectionView) -> CGSize {
        var size = cellSizeToFit(text: content, labelName: "label" , maxSize: CGSizeMake(-1, 300))
        size.height = min(size.height, 200)
        return size
    }
}


//============ API Mocks ==========
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
    var callback: (content: [String]?, error: NSError?)->Void
    
    init(offset:Int, pageSize:Int, callback: (content: [String]?, error: NSError?)->Void) {
        self.callback = callback
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            if !self.wasCancelled {
                if offset > 3 {
                    print("completed")
                    callback(content: nil, error: nil)
                } else {
                    print("loaded")
                    callback(content: ["Maria", "Ion"], error: nil)
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
    var callback: (content: [String]?, nextOffset:String?, error: NSError?)->Void
    
    init(offset:String?, limit:Int, callback: (content: [String]?, nextOffset:String?, error: NSError?)->Void) {
        self.callback = callback
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            print("test")
            if !self.wasCancelled {
                if offset == nil {
                    callback(content: nil, nextOffset: "1", error: nil)
                } else if offset == "1" {
                    callback(content: ["Ion"], nextOffset: "2", error: nil)
                } else if offset == "2" {
                    callback(content: [""], nextOffset: "3", error: nil)
                } else if offset == "3" {
                    callback(content: nil, nextOffset: "4", error: nil)
                } else if offset == "4" {
                    callback(content: ["Maria"], nextOffset: "5", error: nil)
                } else if offset == "5" {
                    callback(content: [""], nextOffset: nil, error: nil)
                }
            }
        }
    }
}


//----------- Your code ------
let feedController = CollectionFeedController()
feedController.addPullToRefresh()
//feedController.dataSource = DataSource<String>(pageSize: 2, loadPage: { (offset, pageSize, callback) -> TTCancellable? in
//    return APIPaginatedMock(offset: offset, pageSize: pageSize, callback: callback)
//})
feedController.dataSource = DataSource<String> (pageSize: 2, loadPage: { return APIPaginatedMock(offset: $0, pageSize: $1, callback: $2) })

feedController.cellController = TextCellController()
feedController.pullToRefreshAction(feedController)

let items = NSArray(arrayLiteral: "Why Algorithms as Microservices are Changing Software Development\n We recently wrote about how the Algorithm Economy and containers have created a fundamental shift in software development. Today, we want to look at the 10 ways algorithms as microservices change the way we build and deploy software.")
let dataSource = DataSource<String>(items)
//dataSource.feed = PaginatedDataFeed<String, String>(loadPage: { (offset, callback) -> TTCancellable? in
//    return APIPaginateOffsetdMock(offset: offset, limit: 10, callback: callback)
//})
//
//feedController.dataSource = dataSource
//let dataSource = DataSource { (offset:String?, callback: TTCallbackNextOffset<String, String>.Signature) -> TTCancellable? in
//    return APIPaginateOffsetdMock(offset: offset, limit: 10, callback: callback)
//}


import XCPlayground
XCPlaygroundPage.currentPage.liveView = feedController
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [Next](@next)
