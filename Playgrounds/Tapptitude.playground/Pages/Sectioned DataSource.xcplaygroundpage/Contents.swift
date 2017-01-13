//: [Previous](@previous)

import UIKit
import Tapptitude


let items = ["Test", "Ghita", "Maria", "Collection", "Cell", "Controller"]
print(items)
print(items.groupBy({ $0.characters.first!.debugDescription }))

let dataSource = SectionedDataSource([["Test", "Ghita"], ["Maria"], ["Collection", "Cell", "Controller"]])
dataSource.filter { $0.characters.count > 4 }

let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = TextCellController()
feedController.animatedUpdates = true

dataSource.dataFeed(nil, didLoadMoreContent: [["Nenea"]])
dataSource[0, 0] = "Ion"
let indexPath = IndexPath(item: 0, section: 0)
dataSource[indexPath] = "New Ion"

print(dataSource.content)
let testDataSource = SectionedDataSource<String>(NSArray(array: [["Test"]]))

DispatchQueue.main.asyncAfter(deadline: .now() + 2) { 
    dataSource[1] = ["Ioana Moldovan", "Maria"]
}

import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view
//: [Next](@next)
