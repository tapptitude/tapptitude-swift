//: [Previous](@previous)

import UIKit
import Tapptitude


// 1 cell controller --------

// 2 cell controller --------
let grayCellController = CollectionCellController<String, TextCell>(cellSize: CGSize(width: -1, height: 70))
grayCellController.minimumInteritemSpacing = 20
grayCellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = UIColor.gray
    cell.label.textColor = UIColor.white
    cell.label.text = content
}
grayCellController.didSelectContent = { content, indexPath, collectionView in
    print("did select", content)
}

// 3 cell controllers --------
let numberCellController = IntCellController(cellSize: CGSize(width: -1, height: 20))
let textCellController = TextCellController(cellSize: CGSize(width: -1, height: 50))

// datasource
let dataSource = DataSource(["John", "Doe", 11])
let multiCellController = HybridCellController([textCellController, numberCellController, grayCellController])

let feedController = CollectionFeedController()
feedController.dataSource = HybridDataSource(content: ["John", "Doe", 11], multiCellController: multiCellController)
feedController.cellController = multiCellController

import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view

//: [Next](@next)
