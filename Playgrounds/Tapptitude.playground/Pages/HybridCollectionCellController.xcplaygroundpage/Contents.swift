//: [Previous](@previous)

import UIKit
import Tapptitude

struct TestModel {
    var name = "Maria"
    var displayedCount = "23"
    var count = 23
}

// 1 cell controller --------
extension TextCellController: HybridCollectionCellController {
    public func mapItem(_ item: Any) -> [Any] {
        if let item = item as? TestModel {
            return [item.name]
        } else {
            return []
        }
    }
}

// 2 cell controller --------
extension BrownTextCellController: HybridCollectionCellController {
    public func mapItem(_ item: Any) -> [Any] {
        if let item = item as? TestModel {
            return [item.displayedCount]
        } else {
            return []
        }
    }
}



// 3 cell controller --------
extension IntCellController: HybridCollectionCellController {
    public func mapItem(_ item: Any) -> [Any] {
        if let item = item as? TestModel {
            return [item.count]
        } else {
            return []
        }
    }
}

let multiCellController = HybridCellController(TextCellController(), BrownTextCellController(), IntCellController())

let feedController = CollectionFeedController()
feedController.dataSource = HybridDataSource(content: [TestModel()], multiCellController: multiCellController)
feedController.cellController = multiCellController

import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view
