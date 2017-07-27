//: [Previous](@previous)

import Foundation
import Tapptitude

let dataSource = SectionedDataSource<Any>([["Maria"], [23]])

let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = MultiCollectionCellController(TextCellController(), IntCellController())
feedController.headerController = MultiHeaderCellController(IntHeaderCellController(), StringHeaderCellController())

import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view

//: [Next](@next)
