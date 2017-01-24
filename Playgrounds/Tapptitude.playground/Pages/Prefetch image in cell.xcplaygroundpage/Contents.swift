//: [Previous](@previous)

import UIKit
import Tapptitude

extension TextCellController: CollectionCellPrefetcher {
    public func prefetchItems(_ items: [String], at indexPaths: [IndexPath], in collectionView: UICollectionView) {
        
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

//: [Next](@next)
