//: [Previous](@previous)

import UIKit
import Tapptitude

class TextCellController: CollectionCellController<String, TextCell> {
    init() {
        super.init(cellSize: CGSize(width: -1, height: 50))
        minimumInteritemSpacing = 10
        sectionInset = UIEdgeInsetsMake(0, 0, 10, 0)
    }
    
    override func configureCell(_ cell: TextCell, for content: String, at indexPath: IndexPath) {
        cell.label.text = content
    }
    
    override func cellSize(for content: String, in collectionView: UICollectionView) -> CGSize {
        var size = cellSizeToFit(text: content, label: sizeCalculationCell.label, maxSize: CGSize(width:-1, height:300))
        size.height = min(size.width, 200)
        return size
    }
}

extension URLSessionTask: TTCancellable {
    
}

let url = URL(string: "https://httpbin.org/get")
var url_request = URLRequest(url: url!)

let feed = SimpleDataFeed<String> { (callback) -> TTCancellable? in
    let task = URLSession.shared.dataTask(with: url_request) { data , response , error  in
        let stringResponse = data != nil ? String(data: data!, encoding: String.Encoding.utf8) : nil
        let items: [String]? = stringResponse != nil ? [stringResponse!] : nil
        print(error)
        
        DispatchQueue.main.async {
            callback(items, error as? NSError)
        }
    }
    task.resume()
    
    return task
}

let feedController = CollectionFeedController()
feedController.dataSource = DataSource<String>(feed: feed)
feedController.cellController = TextCellController()


import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view
PlaygroundPage.current.needsIndefiniteExecution = true
//: [Next](@next)
