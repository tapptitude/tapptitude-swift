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
    
    override func configureCell(_ cell: TextCell, for content: String, at indexPath: IndexPath) {
        cell.label.text = content
    }
    
    override func cellSize(for content: String, in collectionView: UICollectionView) -> CGSize {
        var size = cellSizeToFit(text: content, label: sizeCalculationCell.label , maxSize: CGSize(width: -1, height: 300))
        size.height = min(size.height, 200)
        return size
    }
}


//============ API Mocks ==========
class APIPaginatedMock: TTCancellable {
    func cancel() {
        wasCancelled = true
    }

    var wasCancelled = false
    var callback: ((_ content: [String]?, _ error: Error?) -> ())!
    
    init(offset:Int, pageSize:Int, callback: @escaping ((_ content: [String]?, _ error: Error?)->())) {
        self.callback = callback
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if !self.wasCancelled {
                if offset > 3 {
                    print("completed")
                    callback(nil, nil)
                } else {
                    print("loaded")
                    callback(["Maria", "Ion"], nil)
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
    var callback: (_ content: [String]?, _ nextOffset:String?, _ error: Error?)->()
    
    init(offset:String?, callback: @escaping (_ content: [String]?, _ nextOffset:String?, _ error: Error?)->()) {
        self.callback = callback
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            print("test")
            if !self.wasCancelled {
                if offset == nil {
                    callback(nil, "1", nil)
                } else if offset == "1" {
                    callback(["Ion"], "2", nil)
                } else if offset == "2" {
                    callback([""], "3", nil)
                } else if offset == "3" {
                    callback(nil, "4", nil)
                } else if offset == "4" {
                    callback(["Maria"], "5", nil)
                } else if offset == "5" {
                    callback([""], nil, nil)
                }
            }
        })
    }
}

class API {
    class func getPaginatedMock(offset:Int, pageSize:Int, callback:
        @escaping (_ content: [String]?, _ error: Error?)->()) -> TTCancellable? {
        return APIPaginatedMock(offset: offset, pageSize: pageSize, callback: callback)
    }
    
    class func getPaginatedOffsetMock(offset:String?, callback: @escaping
        (_ content: [String]?, _ nextOffset: String?, _ error: Error?)->()) -> TTCancellable? {
        return APIPaginateOffsetdMock(offset: offset, callback: callback)
    }
}

//----------- Your code ------
let items = NSArray(arrayLiteral: "Why Algorithms as Microservices are Changing Software Development\n We recently wrote about how the Algorithm Economy and containers have created a fundamental shift in software development. Today, we want to look at the 10 ways algorithms as microservices change the way we build and deploy software.")
var dataSource = DataSource<String>(items)

let feed = PaginatedDataFeed<String, Int>(pageSize: 2, loadPage: API.getPaginatedMock)
//let feed = PaginatedDataFeed<String, String>(loadPage: API.getPaginatedOffsetMock)

dataSource.feed = feed

let feedController = CollectionFeedController()
feedController.addPullToRefresh()
feedController.cellController = TextCellController()
feedController.pullToRefreshAction(feedController)
feedController.dataSource = dataSource


import PlaygroundSupport
PlaygroundPage.current.liveView = feedController
PlaygroundPage.current.needsIndefiniteExecution = true
//: [Next](@next)
