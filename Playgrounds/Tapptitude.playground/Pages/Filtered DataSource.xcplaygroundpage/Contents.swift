//: [Previous](@previous)

import UIKit
import Tapptitude

let items = ["Test", "Ghita", "Maria", "Collection", "Cell", "Controller"]

let dataSource = FilteredDataSource(items)
dataSource.filter(by: { $0.characters.count <= 4 })
print(dataSource.content)

let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = TextCellController()

let content = Result<[Any]>.success(["Nenea"] as [Any])
dataSource.dataFeed(nil, didLoadResult: content, forState: .loadingMore)

DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    dataSource.filter(by: nil)
}

print(dataSource.content)

import PlaygroundSupport
feedController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 600)
PlaygroundPage.current.liveView = feedController.view


//: [Next](@next)
