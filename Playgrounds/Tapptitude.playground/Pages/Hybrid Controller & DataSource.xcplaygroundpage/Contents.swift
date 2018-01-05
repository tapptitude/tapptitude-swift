//: [Previous](@previous)

import UIKit
import Tapptitude


// 3 cell controllers --------
let textCellController = TextCellController(cellSize: CGSize(width: 320, height: 50))
let numberCellController = IntCellController(cellSize: CGSize(width: -1, height: 20))
let brownCellController = BrownTextCellController()

// datasource
let content: [Any] = ["John", "Doe", 11]
let multiCellController = HybridCellController(textCellController, numberCellController, brownCellController)

let feedController = CollectionFeedController()
feedController.dataSource = HybridDataSource(content:content, multiCellController: multiCellController)
feedController.cellController = multiCellController

import PlaygroundSupport
feedController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 600)
PlaygroundPage.current.liveView = feedController.view

//: [Next](@next)
