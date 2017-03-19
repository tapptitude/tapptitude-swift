//: [Previous](@previous)

import UIKit
import Tapptitude

extension URLSessionTask: TTCancellable {
    
}

let url = URL(string: "https://httpbin.org/get")
var url_request = URLRequest(url: url!)

let feed = SimpleFeed<String> { (callback) -> TTCancellable? in
    let task = URLSession.shared.dataTask(with: url_request) { data , response , error  in
        let stringResponse = data != nil ? String(data: data!, encoding: String.Encoding.utf8) : nil
        let items: [String]? = stringResponse != nil ? [stringResponse!] : nil
        print(error as Any)
        
        DispatchQueue.main.async {
            if let items = items {
                let result = Result.success(items)
                callback(result)
            } else {
                let result = Result<[String]>.failure(error!)
                callback(result)
            }
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
