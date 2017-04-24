//: [Previous](@previous)

import UIKit
import Tapptitude

extension TextCellController: CollectionCellPrefetcher {
    public func prefetchItems(_ items: [String], at indexPaths: [IndexPath], in collectionView: UICollectionView) {
        print("prefetch", items)
    }
    
    public func cancelPrefetchItems(_ items: [String], at indexPaths: [IndexPath], in collectionView: UICollectionView) {
        
    }
}

let items = ["Test", "Ghita", "Maria", "Collection", "Cell", "Controller"]
let dataSource = DataSource(items)


let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = TextCellController()

print(dataSource.content)

import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view



// testing if multi cellcontroller supports prefetching
print(feedController.cellController.supportsDataSourcePrefetching())
let multiCellController = MultiCollectionCellController(feedController.cellController)
let anyCellController = multiCellController as TTAnyCollectionCellController
print(multiCellController.supportsDataSourcePrefetching())
print(anyCellController.supportsDataSourcePrefetching())
let wCellController = MultiCollectionCellController() as TTAnyCollectionCellController
print(wCellController.supportsDataSourcePrefetching())

//: [Next](@next)
