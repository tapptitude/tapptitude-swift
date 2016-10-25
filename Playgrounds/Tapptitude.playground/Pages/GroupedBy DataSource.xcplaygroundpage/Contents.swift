//: [Previous](@previous)

import UIKit
import Tapptitude

let items = ["Test", "Ghita", "Maria", "Collection", "Cell", "Controller"]
print(items)
print(items.groupBy({ $0.characters.first!.debugDescription }))

//[["Test", "Ghita"], ["Maria"], ["Collection", "Cell", "Controller"]]
let dataSource = GroupedByDataSource(content: items, groupBy: { $0.characters.first!.debugDescription })
dataSource.filter { $0.characters.count > 4 }

let cellController = CollectionCellController<String, TextCell>(cellSize: CGSize(width: 50, height: 50))
cellController.minimumInteritemSpacing = 10
cellController.sectionInset = UIEdgeInsetsMake(0, 0, 10, 0)
cellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = UIColor.red
    cell.label.text = content
}
cellController.cellSizeForContent = {[weak cellController] (content, _) in
    return cellController!.cellSizeToFit(text: content, labelName: "label", maxSize: CGSize(width: 300, height: -1))
}

let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = cellController

dataSource.dataFeed(nil, didLoadMoreContent: ["Ion"])
dataSource.filter(nil)

import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view
//: [Next](@next)
