//: [Previous](@previous)

import UIKit
import Tapptitude

let items = ["Test", "Ghita", "Maria", "Collection", "Cell", "Controller"]
print(items)
print(items.groupBy({ $0.characters.first!.debugDescription }))

//[["Test", "Ghita"], ["Maria"], ["Collection", "Cell", "Controller"]]
let dataSource = GroupedByDataSource(content: items, groupBy: { $0.characters.first!.debugDescription })
dataSource.filter { $0.characters.count > 4 }


let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = TextCellController()

dataSource.dataFeed(nil, didLoadResult: .success(["Ion"]), forState: .loadingMore)


DispatchQueue.main.asyncAfter(deadline: .now() + 3) { 
    dataSource.filter(nil)
}

import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view
//: [Next](@next)
