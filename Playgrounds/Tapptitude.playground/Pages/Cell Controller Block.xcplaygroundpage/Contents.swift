//: Playground - noun: a place where people can play

import UIKit
import Tapptitude


let dataSource = DataSource(["test"])
let cellController = CollectionCellController<String, UICollectionViewCell>(cellSize: CGSize(width: 50, height: 50))
cellController.acceptsContent("test")
cellController.acceptsContent(1)
cellController.acceptsContent("Maria" as AnyObject)
let indexPath = IndexPath(item: 0, section: 0)
let object = dataSource[indexPath]
cellController.configureCell(UICollectionViewCell(), for: object, at: indexPath)
cellController.parentViewController = nil
cellController.parentViewController = UIViewController()

let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = cellController

print(feedController.view)
feedController.collectionView?.backgroundColor = UIColor.gray


cellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = UIColor.red
    print(cell)
}
cellController.didSelectContent = { content, indexPath, collectionView in
    print("did select", content)
    let cell = collectionView.cellForItem(at: indexPath)
    print(cellController.parentViewController!)
}
print(feedController.collectionView)

import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view
