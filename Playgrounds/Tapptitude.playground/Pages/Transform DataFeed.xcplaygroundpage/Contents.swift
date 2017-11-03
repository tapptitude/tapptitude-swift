//: [Previous](@previous)

import Foundation
import UIKit
import Tapptitude

extension URLSessionTask: TTCancellable {
    
}


// dummy API call used by the feed
class API {
    static func getHackerNews(callback: @escaping (_ result: Result<[String]>) -> ()) -> TTCancellable? {
        let url = URL(string: "https://news.ycombinator.com/news")
        let url_request = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: url_request) { data , response , error  in
            let stringResponse = data != nil ? String(data: data!, encoding: String.Encoding.utf8) : nil
            let items: [String]? = stringResponse != nil ? [stringResponse!] : nil
            print(error ?? "")
            
            DispatchQueue.main.async {
                if let items = items {
                    let result = Result.success(items)
                    callback(result)
                } else {
                    callback(.failure(error!))
                }
            }
        }
        task.resume()
        
        return task
    }
}












let feedController = CollectionFeedController()
feedController.cellController = MultiCollectionCellController([BrownTextCellController(), IntCellController()])

// show spinner while loading
// pull to refresh functionality
// load more functionality if PaginatedDataFeed is used
// no need to handle error case, done by the feedcontroller

let feed = SimpleFeed(load: API.getHackerNews(callback: ))
feed.setTransform { (content, offset, state) -> [Any] in // transform your content
    var newContent: [Any] = []
    content.forEach({ item in
        newContent.append(item)
        newContent.append("Page Size: \(item.count) characters")
        newContent.append(item.count)
    })
    return newContent
}
feedController.dataSource = DataSource<Any>(feed: feed)



/// this is old alternative of the code above
//API.getHackerNews { (result) in
//    switch result {
//    case .success(let content):
//        var newContent: [Any] = []
//        content.forEach({ item in
//            newContent.append(item)
//            newContent.append("Page Size: \(item.count) characters")
//            newContent.append(item.count)
//        })
//        feedController.dataSource = DataSource(newContent)
//    case .failure(let error):
//        feedController.checkAndShow(error: error)
//    }
//}







import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view
PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)

