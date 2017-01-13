//: [Previous](@previous)

import UIKit
import Tapptitude

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
feedController.cellController = BrownTextCellController()


import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view
PlaygroundPage.current.needsIndefiniteExecution = true
//: [Next](@next)
