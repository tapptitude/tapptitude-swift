//: [Previous](@previous)

import UIKit
import Tapptitude


let items = ["Test", "Ghita", "Maria", "Collection", "Cell", "Controller"]
print(items)
print(items.groupBy({ $0.first!.debugDescription }))

let dataSource = SectionedDataSource([["Test", "Ghita"], ["Maria"], ["Collection", "Cell", "Controller"]])
dataSource.filter { $0.count > 4 }

let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = TextCellController()
feedController.animatedUpdates = true

dataSource.dataFeed(nil, didLoadResult: .success([["Nenea"]]), forState: .loadingMore)
dataSource[0, 0] = "Ion"
let indexPath = IndexPath(item: 0, section: 0)
dataSource[indexPath] = "New Ion"

print(dataSource.content)
let testDataSource = SectionedDataSource<String>(NSArray(array: [["Test"]]))

DispatchQueue.main.asyncAfter(deadline: .now() + 2) { 
    dataSource[1] = ["Ioana Moldovan", "Maria"]
}

DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    dataSource.insert(sections: [["Lol"]], at: 0)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
    dataSource.insert(sections: [["Test1"],  ["Test 2"]], at: 1)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    dataSource.insert(sections: [[]], at: 0)
}

import PlaygroundSupport
feedController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 600)
PlaygroundPage.current.liveView = feedController.view
//: [Next](@next)
