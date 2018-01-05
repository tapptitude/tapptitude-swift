//: Playground - noun: a place where people can play

import UIKit
import Tapptitude

class TextCellController: CollectionCellController<String, UICollectionViewCell> {
    init() {
        super.init(cellSize: CGSize(width: 50, height: 50))
    }
    
    override func configureCell(_ cell: UICollectionViewCell, for content: String, at indexPath: IndexPath) {
        cell.backgroundColor = UIColor.red
        print("configure ", cell, "with: ", content)
    }
    
    override func didSelectContent(_ content: String, at indexPath: IndexPath, in collectionView: UICollectionView) {
        print("did select", content)
        let cell = collectionView.cellForItem(at: indexPath)!
        print("parent ", cell.parentViewController!)
    }
}

let dataSource = DataSource(["test"])
let cellController = TextCellController()
cellController.acceptsContent("test")
cellController.acceptsContent(1)
cellController.acceptsContent("Maria" as AnyObject)
let indexPath = IndexPath(item: 0, section: 0)
let object: String = dataSource[indexPath]
cellController.configureCell(UICollectionViewCell(), for: object, at: indexPath)

let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = cellController
print(cellController.parentViewController)

let _ = feedController.view // load it's view
feedController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 600)
feedController.collectionView?.backgroundColor = UIColor.gray

import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view
