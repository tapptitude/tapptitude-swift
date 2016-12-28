//: [Previous](@previous)

import UIKit
import Tapptitude


let items = ["Test", "Ghita", "Maria", "Collection", "Cell", "Controller"]
print(items)
print(items.groupBy({ $0.characters.first!.debugDescription }))

let dataSource = SectionedDataSource([["Test", "Ghita"], ["Maria"], ["Collection", "Cell", "Controller"]])
dataSource.filter { $0.characters.count > 4 }

let cellController = CollectionCellController<String, TextCell>(cellSize: CGSize(width: 50, height: 50))
cellController.sectionInset = UIEdgeInsetsMake(0, 0, 10, 0)
cellController.minimumInteritemSpacing = 10
cellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = UIColor.red
    cell.label.text = content
}
cellController.cellSizeForContent = {[unowned cellController] (content, _) in
    return cellController.cellSizeToFit(text: content, label: cellController.sizeCalculationCell.label, maxSize: CGSize(width: 300, height: -1))
}

let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = cellController

dataSource.dataFeed(nil, didLoadMoreContent: [["Nenea"]])
dataSource[0, 0] = "Ion"
let indexPath = IndexPath(item: 0, section: 0)
dataSource[indexPath] = "New Ion"

print(dataSource.content)
let testDataSource = SectionedDataSource<String>(NSArray(array: [["Test"]]))

import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view
//: [Next](@next)
