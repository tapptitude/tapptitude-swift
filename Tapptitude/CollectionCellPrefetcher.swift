//
//  CollectionCellPrefetcher.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 17/01/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import UIKit

/// available on iOS 10+, will give a chance to do content prefetcing before cell is displayed
public protocol CollectionCellPrefetcher: TTCollectionCellPrefetcher {
    associatedtype ContentType
    
    func prefetchItems(_ items: [ContentType], at indexPaths: [IndexPath], in collectionView: UICollectionView)
    func cancelPrefetchItems(_ items: [ContentType], at indexPaths: [IndexPath], in collectionView: UICollectionView)
}


public extension CollectionCellPrefetcher {
    
    func prefetchItems(_ items: [Any], at indexPaths: [IndexPath], in collectionView: UICollectionView) {
        prefetchItems(items as! [ContentType], at: indexPaths, in: collectionView)
    }
    
    func cancelPrefetchItems(_ items: [Any], at indexPaths: [IndexPath], in collectionView: UICollectionView) {
        cancelPrefetchItems(items as! [ContentType], at: indexPaths, in: collectionView)
    }
}

public protocol TTCollectionCellPrefetcher {
    func prefetchItems(_ items: [Any], at indexPaths: [IndexPath], in collectionView: UICollectionView)
    func cancelPrefetchItems(_ items: [Any], at indexPaths: [IndexPath], in collectionView: UICollectionView)
}

class CollectionCellPrefetcherDelegate: NSObject, UICollectionViewDataSourcePrefetching {
    weak var collectionController: __CollectionFeedController!
    
    init(collectionController: __CollectionFeedController) {
        self.collectionController = collectionController
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if let prefetcher = collectionController._cellController as? TTCollectionCellPrefetcher {
            let content: [Any] = indexPaths.map{ collectionController._dataSource!.item(at: $0) }
            prefetcher.prefetchItems(content, at: indexPaths, in: collectionView)
        }
    }
    
    
    // indexPaths that previously were considered as candidates for pre-fetching, but were not actually used; may be a subset of the previous call to -collectionView:prefetchItemsAtIndexPaths:
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        if let prefetcher = collectionController._cellController as? TTCollectionCellPrefetcher {
            let content: [Any] = indexPaths.map{ collectionController._dataSource!.item(at: $0) }
            prefetcher.cancelPrefetchItems(content, at: indexPaths, in: collectionView)
        }
    }
}


public extension TTAnyCollectionCellController {
    func supportsDataSourcePrefetching() -> Bool {
        switch self {
        case let cellController as MultiCellController:
            return cellController.supportsDataSourcePrefetching()
        case is TTCollectionCellPrefetcher:
            return true
        default:
            return false
        }
    }
}

extension MultiCellController: TTCollectionCellPrefetcher {
    public func supportsDataSourcePrefetching() -> Bool {
        return cellControllers.filter{ $0.supportsDataSourcePrefetching() }.isEmpty == false
    }
    
    public func prefetchItems(_ items: [Any], at indexPaths: [IndexPath], in collectionView: UICollectionView) {
        filterItems(items, at: indexPaths, completion: { prefetcher, newItems, newIndexPath in
            prefetcher.prefetchItems(newItems, at: newIndexPath, in: collectionView)
        })
    }
    
    public func cancelPrefetchItems(_ items: [Any], at indexPaths: [IndexPath], in collectionView: UICollectionView) {
        filterItems(items, at: indexPaths, completion: { prefetcher, newItems, newIndexPath in
            prefetcher.cancelPrefetchItems(newItems, at: newIndexPath, in: collectionView)
        })
    }
    
    func filterItems(_ items: [Any], at indexPaths: [IndexPath], completion: (_ prefetcher: TTCollectionCellPrefetcher, _ items: [Any], _ indexPaths:[IndexPath]) -> ()) {
        let prefetchers = cellControllers.filter{ $0.supportsDataSourcePrefetching() }
        for cellController in prefetchers {
            var newItems: [Any] = []
            var newIndexPath: [IndexPath] = []
            for (index, item) in items.enumerated() {
                if cellController.acceptsContent(item) {
                    newItems.append(item)
                    newIndexPath.append(indexPaths[index])
                }
            }
            
            if !newItems.isEmpty {
                completion(cellController as! TTCollectionCellPrefetcher, newItems, newIndexPath)
            }
        }
    }
}



extension __CollectionFeedController {
    internal func updatePrefetcherController() {
        if #available(iOS 10.0, *) {
            
            if let cellController = self._cellController, cellController.supportsDataSourcePrefetching()  {
                prefetchController = CollectionCellPrefetcherDelegate(collectionController: self)
            } else {
                prefetchController = nil
            }
            
            collectionView?.prefetchDataSource = prefetchController
        }
    }
}
