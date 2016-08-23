//: [Previous](@previous)

import Foundation
import Tapptitude

import UIKit
import XCPlayground

var dataSource = DataSource([2, 4, 6])

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


func dispatch_after_on_main_queue (delayInSeconds: Double , closure: ()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW,  Int64(delayInSeconds * Double(NSEC_PER_SEC)));
    dispatch_after(popTime, dispatch_get_main_queue(), closure);
}


dataSource.perfomBatchUpdates({ 
    dataSource.append(232)
    }) { 
        dataSource.remove(at: NSIndexPath(forItem: 0, inSection: 0))
}


dataSource.perfomBatchUpdates({
    dataSource.remove(at: NSIndexPath(forItem: 0, inSection: 0))
    dataSource.insert(34, at: NSIndexPath(forItem: 1, inSection: 0))
    dataSource.insert(34, at: NSIndexPath(forItem: 1, inSection: 0))
    dataSource.append(23)
    dataSource.append(29)
    }, animationCompletion: {
        print("completed all animations at once")
        
        feedController.animatedUpdates = false
        dataSource.remove({ (item) -> Bool in
            return item < 10
        })
})
