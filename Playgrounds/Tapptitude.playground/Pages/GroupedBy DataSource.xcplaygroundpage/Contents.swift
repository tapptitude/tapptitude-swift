//: [Previous](@previous)

import UIKit
import Tapptitude

let items = ["Test", "Ghita", "Maria", "Collection", "Cell", "Controller"]
print(items)
print(items.groupBy({ $0.first!.debugDescription }))

//[["Test", "Ghita"], ["Maria"], ["Collection", "Cell", "Controller"]]
let dataSource = GroupedByDataSource(content: items, groupBy: { $0.first!.debugDescription })
dataSource.filter { $0.count > 4 }


let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = TextCellController()

dataSource.dataFeed(nil, didLoadResult: .success(["Ion"]), forState: .loadingMore)


DispatchQueue.main.asyncAfter(deadline: .now() + 3) { 
    dataSource.filter(nil)
}

import PlaygroundSupport
feedController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 600)
PlaygroundPage.current.liveView = feedController.view
//: [Next](@next)
