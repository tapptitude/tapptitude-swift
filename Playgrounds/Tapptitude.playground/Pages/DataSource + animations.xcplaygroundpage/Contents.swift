//: [Previous](@previous)

import Foundation
import Tapptitude

import UIKit
import PlaygroundSupport

var dataSource = DataSource([2, 4, 6])

let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = IntCellController()

PlaygroundPage.current.liveView = feedController.view


feedController.perfomBatchUpdates({
    dataSource.append(232)
    }) {
        dataSource.remove(at: IndexPath(item: 0, section: 0))
}


feedController.perfomBatchUpdates({
    dataSource.remove(at: IndexPath(item: 0, section: 0))
    dataSource.insert(34, at: IndexPath(item: 1, section: 0))
    dataSource.insert(34, at: IndexPath(item: 1, section: 0))
    dataSource.append(23)
    dataSource.append(29)
    }, animationCompletion: {
        print("completed all animations at once")
        
        feedController.perfomBatchUpdates({ 
            dataSource.remove{ $0 < 10 }
        }, animationCompletion: {
            feedController.collectionView.performBatchUpdates({ 
                dataSource.remove{ $0 < 100 }
            })
        })
})
