//: [Previous](@previous)

import UIKit
import Tapptitude

let dataSource = SectionedDataSource<Any>([["Maria"], [23]])

let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = MultiCollectionCellController(TextCellController(), IntCellController())
feedController.headerController = MultiHeaderCellController(IntHeaderCellController(), StringHeaderCellController())

import PlaygroundSupport
feedController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 600)
PlaygroundPage.current.liveView = feedController.view

//: [Next](@next)

var headerController1: MultiHeaderCellController = [IntHeaderCellController(), StringHeaderCellController()] //@protocol ExpressibleByArrayLiteral
print(headerController1.headerControllers)
