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
    cell.backgroundColor = UIColor.redColor()
    cell.label.text = content
}
cellController.cellSizeForContent = { (content, _) in
    return cellController.cellSizeToFitText(content, labelName: "label", maxSize: CGSize(width: 300, height: -1))
}

let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = cellController

dataSource.dataFeed(nil, didLoadMoreContent: [["Nenea"]])
dataSource[0, 0] = "Ion"

print(dataSource.content)
let testDataSource = SectionedDataSource<String>(NSArray(array: [["Test"]]))

import XCPlayground
XCPlaygroundPage.currentPage.liveView = feedController.view
//: [Next](@next)
