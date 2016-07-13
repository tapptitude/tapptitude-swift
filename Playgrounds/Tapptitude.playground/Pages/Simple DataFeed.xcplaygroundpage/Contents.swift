//: [Previous](@previous)

import UIKit
import Tapptitude

class TextCellController: CollectionCellController<String, TextCell> {
    init() {
        super.init(cellSize: CGSize(width: -1, height: 50))
        minimumInteritemSpacing = 10
        sectionInset = UIEdgeInsetsMake(0, 0, 10, 0)
    }
    
    override func configureCell(cell: TextCell, for content: String, at indexPath: NSIndexPath) {
        cell.label.text = content
    }
    
    override func cellSize(for content: String, in collectionView: UICollectionView) -> CGSize {
        var size = cellSizeToFitText(content, labelName: "label" , maxSize: CGSizeMake(-1, 300))
        size.height = min(size.width, 200)
        return size
    }
}

extension NSURLSessionTask: TTCancellable {
    
}

let url = NSURL(string: "https://httpbin.org/get")
var url_request = NSMutableURLRequest(URL: url!)

let feed = SimpleDataFeed<String> { (callback) -> TTCancellable? in
    let task = NSURLSession.sharedSession().dataTaskWithRequest(url_request) { data , response , error  in
        let stringResponse = data != nil ? String(data: data!, encoding: NSUTF8StringEncoding) : nil
        let items: [String]? = stringResponse != nil ? [stringResponse!] : nil
        print(error)
        
        dispatch_async(dispatch_get_main_queue()) {
            callback(content: items, error: error)
        }
    }
    task.resume()
    
    return task
}

let feedController = CollectionFeedController()
feedController.dataSource = DataSource(feed: feed)
feedController.cellController = TextCellController()


import XCPlayground
XCPlaygroundPage.currentPage.liveView = feedController.view
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [Next](@next)
