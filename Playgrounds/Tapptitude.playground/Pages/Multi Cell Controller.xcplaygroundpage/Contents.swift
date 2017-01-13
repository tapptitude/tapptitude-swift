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
PlaygroundPage.current.liveView = feedController.view


//: [Next](@next)
