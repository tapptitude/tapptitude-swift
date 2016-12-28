//: [Previous](@previous)

import Foundation
import UIKit
import Tapptitude

class TextCellController: CollectionCellController<String, TextCell> {
    init() {
        super.init(cellSize: CGSize(width: -1, height: 50))
        minimumInteritemSpacing = 10
        minimumLineSpacing = 20
        sectionInset = UIEdgeInsetsMake(0, 0, 10, 0)
    }
    
    override func configureCell(_ cell: TextCell, for content: String, at indexPath: IndexPath) {
        cell.label.text = content
        cell.backgroundColor = .brown
    }
    
    override func cellSize(for content: String, in collectionView: UICollectionView) -> CGSize {
        var size = cellSizeToFit(text: content, label: sizeCalculationCell.label , maxSize: CGSize(width:-1, height:500))
        size.height = min(size.height, 500)
        return size
    }
}


extension URLSessionTask: TTCancellable {
    
}



class API {
    static func getBin(callback: @escaping (_ items: [String]?, _ error: Error?) -> ()) -> TTCancellable? {
        let url = URL(string: "https://httpbin.org/get")
        let url_request = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: url_request) { data , response , error  in
            let stringResponse = data != nil ? String(data: data!, encoding: String.Encoding.utf8) : nil
            let items: [String]? = stringResponse != nil ? [stringResponse!] : nil
            print(error ?? "")
            
            DispatchQueue.main.async {
                callback(items, error)
            }
        }
        task.resume()
        
        return task
    }
    
    static func getHackerNews(callback: @escaping (_ items: [String]?, _ error: Error?) -> ()) -> TTCancellable? {
        let url = URL(string: "https://news.ycombinator.com/news")
        let url_request = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: url_request) { data , response , error  in
            let stringResponse = data != nil ? String(data: data!, encoding: String.Encoding.utf8) : nil
            let items: [String]? = stringResponse != nil ? [stringResponse!] : nil
            print(error ?? "")
            
            DispatchQueue.main.async {
                callback(items, error)
            }
        }
        task.resume()
        
        return task
    }
    
    static func getHackerNewsParams(param: Int, callback: @escaping (_ items: [String]?, _ error: Error?) -> ()) -> TTCancellable? {
        let url = URL(string: "https://news.ycombinator.com/news")
        let url_request = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: url_request) { data , response , error  in
            let stringResponse = data != nil ? String(data: data!, encoding: String.Encoding.utf8) : nil
            let items: [String]? = stringResponse != nil ? [stringResponse!] : nil
            print(error ?? "")
            
            DispatchQueue.main.async {
                callback(items, error)
            }
        }
        task.resume()
        
        return task
    }
    
    static func getHackerNews(page: Int?, callback: @escaping (_ items: [String]?, _ nextOffset: Int?, _ error: Error?) -> ()) -> TTCancellable? {
        let newPage = page ?? 0
        let url = URL(string: "https://news.ycombinator.com/news?p=\(newPage)")
        let url_request = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: url_request) { data , response , error  in
            let stringResponse = data != nil ? String(data: data!, encoding: String.Encoding.utf8) : nil
            let items: [String]? = stringResponse != nil ? [stringResponse!] : nil
            print(error ?? "")
            
            DispatchQueue.main.async {
                let nextPage = items?.isEmpty == false ? (newPage + 1) : nil
                callback(items, nextPage, error)
            }
        }
        task.resume()
        
        return task
    }
}

let feedController = CollectionFeedController()
let dataSource = DataSource<Any>()

let parallelFeed = ParallelDataFeed()
parallelFeed.reloadOperation.append(operation: API.getBin)
parallelFeed.reloadOperation.append(operation: { callback -> TTCancellable? in
    return API.getHackerNewsParams(param: 1, callback: callback)
})
parallelFeed.reloadOperation.append(operation: API.getHackerNews(page:callback:))

parallelFeed.loadMoreOperation.append(operation: API.getHackerNews(page:callback:))
dataSource.feed = parallelFeed

//dataSource.addOperation(load: API.getBin)
//dataSource.addOperation(load: API.getHackerNews)
//dataSource.addOperation(load: API.getHackerNews)
//dataSource.addOperation(load: { callback -> TTCancellable? in
//    return API.getHackerNewsParams(param: 1, callback: callback)
//})
feedController.dataSource = dataSource
feedController.cellController = TextCellController()


import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view
feedController.addPullToRefresh()
PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
