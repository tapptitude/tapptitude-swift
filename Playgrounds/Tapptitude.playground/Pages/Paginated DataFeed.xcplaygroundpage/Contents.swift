//: [Previous](@previous)

import UIKit
import Tapptitude


//============ API Mocks ==========
class APIPaginatedMock: TTCancellable {
    func cancel() {
        wasCancelled = true
    }

    var wasCancelled = false
    var callback: ((_ result: Result<[String]>) -> ())!
    
    init(offset:Int, pageSize:Int, callback: @escaping ((_ result: Result<[String]>)->())) {
        self.callback = callback
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if !self.wasCancelled {
                if offset > 3 {
                    print("completed")
                    callback(.success([]))
                } else {
                    print("loaded")
                    callback(.success(["Maria", "Ion"]))
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
    var callback: (_ result: Result<([String], String?)>) -> ()
    
    init(offset:String?, callback: @escaping TTCallback<([String], String?)>) {
        self.callback = callback
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            print("test")
            if !self.wasCancelled {
                var touple: ([String], String?) = ([""], "1")
                
                switch offset {
                    case nil:        touple = ([], "1")
                    case .some("1"): touple = (["Ion"], "2")
                    case .some("2"): touple = ([""], "3")
                    case .some("3"): touple = ([], "4")
                    case .some("4"): touple = (["Maria"], "5")
                    case .some("5"): touple = ([""], nil)
                    default: break
                }
                callback(.success(touple))
            }
        })
    }
}

class API {
    class func getPaginatedMock(offset:Int, pageSize:Int, callback:
        @escaping TTCallback<[String]> ) -> TTCancellable? {
        return APIPaginatedMock(offset: offset, pageSize: pageSize, callback: callback)
    }
    
    class func getPaginatedOffsetMock(offset:String?, callback: @escaping
        TTCallback<([String], String?)>) -> TTCancellable? {
        return APIPaginateOffsetdMock(offset: offset, callback: callback)
    }
}

//----------- Your code ------
let items = NSArray(arrayLiteral: "Why Algorithms as Microservices are Changing Software Development\n We recently wrote about how the Algorithm Economy and containers have created a fundamental shift in software development. Today, we want to look at the 10 ways algorithms as microservices change the way we build and deploy software.")
var dataSource = DataSource<String>(items)

let feed = DataFeed<String, Int>(pageSize: 2, loadPage: API.getPaginatedMock)
//let feed = DataFeed<String, String>(loadPage: API.getPaginatedOffsetMock)
//dataSource.setLoadPageOperation(API.getPaginatedOffsetMock)

dataSource.feed = feed

let feedController = CollectionFeedController()

feedController.cellController = BrownTextCellController()
feedController.dataSource = dataSource
let _ = feedController.view
feedController.addPullToRefresh()
feedController.pullToRefreshAction(feedController)


import PlaygroundSupport
feedController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 600)
PlaygroundPage.current.liveView = feedController
PlaygroundPage.current.needsIndefiniteExecution = true
//: [Next](@next)
