//: [Previous](@previous)

import UIKit
import Tapptitude

struct TestModel {
    var name = "Maria"
    var displayedCount = "23"
    var count = 23
}

// 1 cell controller --------
let stringCellController = CollectionCellController<String, TextCell>(cellSize: CGSize(width: 50, height: 50))
stringCellController.minimumInteritemSpacing = 20
stringCellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = UIColor.redColor()
    cell.label.text = content
}

// 2 cell controller --------
let grayCellController = CollectionCellController<String, TextCell>(cellSize: CGSize(width: 50, height: 70))
grayCellController.minimumInteritemSpacing = 20
grayCellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = UIColor.grayColor()
    cell.label.textColor = UIColor.whiteColor()
    cell.label.text = content
}

// 3 cell controller --------
let numberCellController = CollectionCellController<Int, UICollectionViewCell>(cellSize: CGSize(width: 100, height: 50))
numberCellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = UIColor.blueColor()
}


extension CollectionCellController: HybridCollectionCellController {
    public func mapItem(item: Any) -> [Any] {
        if let item = item as? TestModel {
        return [item.name]
        } else {
            return []
        }
    }
}

let multiCellController = HybridCellController([stringCellController, numberCellController, grayCellController])

let feedController = CollectionFeedController()
feedController.dataSource = HybridDataSource(content: [TestModel()], multiCellController: multiCellController)
feedController.cellController = multiCellController

import XCPlayground
XCPlaygroundPage.currentPage.liveView = feedController.view
