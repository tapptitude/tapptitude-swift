//: [Previous](@previous)

import UIKit
import Tapptitude



let firstController = CollectionCellController<String, UICollectionViewCell>(cellSize: CGSize(width: 50, height: 50))
firstController.configureCell = {(cell, content, indexPath) in
    print("firstController " + content)
}

let secondController = CollectionCellController<String, UICollectionViewCell>(cellSize: CGSize(width: 50, height: 50))
secondController.configureCell = {(cell, content, indexPath) in
    print("secondController " + content)
}

let content = NSArray(arrayLiteral: "2")
let cellController = HybridCellController([firstController, secondController])
var dataSource = HybridDataSource(content: ["2"], multiCellController: cellController)

var indexPath = NSIndexPath(forItem: 0, inSection: 0)
let item = dataSource.objectAtIndexPath(indexPath)
let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())

cellController.configureCell(UICollectionViewCell(), forContent: item, indexPath: indexPath)
cellController.minimumLineSpacingForContent(item, collectionView: collectionView)
cellController.minimumLineSpacingForContent(item, collectionView: collectionView)

indexPath = NSIndexPath(forItem: 1, inSection: 0)
cellController.configureCell(UICollectionViewCell(), forContent: dataSource.objectAtIndexPath(indexPath), indexPath: indexPath)

cellController.configureCell(UICollectionViewCell(), forContent: "4", indexPath: indexPath)



//: [Next](@next)
