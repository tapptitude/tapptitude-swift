//: [Previous](@previous)

import UIKit
import Tapptitude


// 1 cell controller --------
let stringCellController = CollectionCellController<String, TextCell>(cellSize: CGSize(width: 320, height: 50))
stringCellController.minimumInteritemSpacing = 20
stringCellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = UIColor.red
    cell.label.text = content
}
stringCellController.didSelectContent = { content, indexPath, collectionView in
    print("did select", content)
}

// 2 cell controller --------
let grayCellController = CollectionCellController<String, TextCell>(cellSize: CGSize(width: 320, height: 70))
grayCellController.minimumInteritemSpacing = 20
grayCellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = UIColor.gray
    cell.label.textColor = UIColor.white
    cell.label.text = content
}
grayCellController.didSelectContent = { content, indexPath, collectionView in
    print("did select", content)
}

// 3 cell controller --------
let numberCellController = CollectionCellController<Int, UICollectionViewCell>(cellSize: CGSize(width: 320, height: 50))
numberCellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = UIColor.blue
}
numberCellController.didSelectContent = { content, indexPath, collectionView in
    print("did select", content)
}


// datasource
let dataSource = DataSource(["John", "Doe", 11])
let multiCellController = HybridCellController([stringCellController, numberCellController, grayCellController])

let feedController = CollectionFeedController()
feedController.dataSource = HybridDataSource(content: ["John", "Doe", 11], multiCellController: multiCellController)
feedController.cellController = multiCellController

import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view

//: [Next](@next)
