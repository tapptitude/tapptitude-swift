//: [Previous](@previous)

import UIKit
import Tapptitude

let items = NSArray(arrayLiteral: "Maria", "232", 23)
let dataSource = DataSource<Any>(items)

let multiCellController = MultiCollectionCellController(TextCellController(), IntCellController())

let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = multiCellController

import PlaygroundSupport
feedController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 600)
PlaygroundPage.current.liveView = feedController.view


//: [Next](@next)
