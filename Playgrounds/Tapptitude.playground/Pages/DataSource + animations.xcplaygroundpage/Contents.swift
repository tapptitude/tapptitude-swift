//: [Previous](@previous)

import Foundation
import Tapptitude

import UIKit
import PlaygroundSupport

var dataSource = DataSource([2, 4, 6])

let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = IntCellController()
feedController.animatedUpdates = true

PlaygroundPage.current.liveView = feedController.view
feedController.collectionView.backgroundColor = UIColor.black


dataSource.perfomBatchUpdates({ 
    dataSource.append(232)
    }) { 
        dataSource.remove(at: IndexPath(item: 0, section: 0))
}


dataSource.perfomBatchUpdates({
    dataSource.remove(at: IndexPath(item: 0, section: 0))
    dataSource.insert(34, at: IndexPath(item: 1, section: 0))
    dataSource.insert(34, at: IndexPath(item: 1, section: 0))
    dataSource.append(23)
    dataSource.append(29)
    }, animationCompletion: {
        print("completed all animations at once")
        
        feedController.animatedUpdates = false
        dataSource.remove({ (item) -> Bool in
            return item < 10
        })
})
