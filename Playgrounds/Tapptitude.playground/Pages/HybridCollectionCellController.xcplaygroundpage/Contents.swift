//: [Previous](@previous)

import UIKit
import Tapptitude

struct TestModel {
    var name = "Maria"
    var displayedCount = "23"
    var count = 23
}

// 1 cell controller --------
class NameCellController: CollectionCellController<String, TextCell> {
    init() {
        super.init(cellSize: CGSize(width: 50, height: 50))
        minimumInteritemSpacing = 20
    }
    
    override func configureCell(_ cell: TextCell, for content: String, at indexPath: IndexPath) {
        cell.backgroundColor = UIColor.red
        cell.label.text = content
    }
}

extension NameCellController: HybridCollectionCellController {
    internal func mapItem(_ item: Any) -> [Any] {
        if let item = item as? TestModel {
            return [item.name]
        } else {
            return []
        }
    }
}

// 2 cell controller --------
class CountCellController: CollectionCellController<String, TextCell> {
    init() {
        super.init(cellSize: CGSize(width: 50, height: 70))
        minimumInteritemSpacing = 20
    }
    
    override func configureCell(_ cell: TextCell, for content: String, at indexPath: IndexPath) {
        cell.backgroundColor = UIColor.gray
        cell.label.textColor = UIColor.white
        cell.label.text = content
    }
}

extension CountCellController: HybridCollectionCellController {
    internal func mapItem(_ item: Any) -> [Any] {
        if let item = item as? TestModel {
            return [item.displayedCount]
        } else {
            return []
        }
    }
}



// 3 cell controller --------
class NumberCellController: CollectionCellController<Int, TextCell> {
    init() {
        super.init(cellSize: CGSize(width: 100, height: 50))
    }
    
    override func configureCell(_ cell: TextCell, for content: Int, at indexPath: IndexPath) {
        cell.backgroundColor = UIColor.blue
    }
}


extension NumberCellController: HybridCollectionCellController {
    internal func mapItem(_ item: Any) -> [Any] {
        if let item = item as? TestModel {
            return [item.count]
        } else {
            return []
        }
    }
}

let multiCellController = HybridCellController([NameCellController(), CountCellController(), NumberCellController()])

let feedController = CollectionFeedController()
feedController.dataSource = HybridDataSource(content: [TestModel()], multiCellController: multiCellController)
feedController.cellController = multiCellController

import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view
