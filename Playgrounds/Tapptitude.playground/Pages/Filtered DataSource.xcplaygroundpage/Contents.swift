//: [Previous](@previous)

import UIKit
import Tapptitude

let items = ["Test", "Ghita", "Maria", "Collection", "Cell", "Controller"]

let dataSource = FilteredDataSource(items)
dataSource.filter(by: { $0.characters.count > 4 })
print(dataSource.content)

let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = TextCellController()

let content = FeedResult<[Any]>.success(["Nenea"] as [Any])
dataSource.dataFeed(nil, didLoadResult: content, forState: .loadingMore)
dataSource.filter(by: nil)

print(dataSource.content)

import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view


//: [Next](@next)
