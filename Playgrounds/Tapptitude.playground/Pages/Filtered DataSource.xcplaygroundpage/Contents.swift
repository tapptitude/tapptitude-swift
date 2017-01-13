//: [Previous](@previous)

import UIKit
import Tapptitude

let items = ["Test", "Ghita", "Maria", "Collection", "Cell", "Controller"]

let dataSource = FilteredDataSource(items)
dataSource.filter({ $0.characters.count > 4 })


let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = TextCellController()

dataSource.dataFeed(nil, didLoadMoreContent: ["Nenea"])
dataSource.filter(nil)

print(dataSource.content)

import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view


//: [Next](@next)
