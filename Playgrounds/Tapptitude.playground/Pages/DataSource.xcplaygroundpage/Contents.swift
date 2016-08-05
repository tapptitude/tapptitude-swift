//: [Previous](@previous)

import Foundation
import Tapptitude

let testDataSource = DataSource<Any>(["23", 3])
testDataSource.remove { ($0 as? String) == "23" }
let items: [Int] = [23, 5]
testDataSource.append(contentsOf: items)
let nr: Int = 12312
testDataSource.append(nr)
testDataSource.remove{$0 as? Int == nr}

var dataSource = DataSource([2, 4, 6])
print(dataSource.content)
dataSource[0]
dataSource[2] = 8
dataSource[1, 1]
dataSource.remove{$0 == nr}
print(dataSource)

dataSource += [12]
dataSource.remove{$0 == 2}

let secondDataSource = DataSource([1, 2, 3])
dataSource += secondDataSource
print(dataSource.content)

let content:[String] = dataSource.map({ "-" + String($0) })
print(content)
dataSource.contains(12)
dataSource.count
dataSource.first
dataSource.last

dataSource.remove { $0 == 2 }
print(dataSource.content)

dataSource.remove({ _ in return true })
print(dataSource.content)


import UIKit
import XCPlayground
let cellController = CollectionCellController<Int, UICollectionViewCell>(cellSize: CGSize(width: 50, height: 50))
cellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = UIColor.redColor()
}
let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = cellController
feedController.animatedUpdates = true

XCPlaygroundPage.currentPage.liveView = feedController.view
feedController.collectionView?.backgroundColor = UIColor.blackColor()

dataSource.append(2)
dataSource.append(3)

dataSource.remove{ _ in return true }

//: [Next](@next)
