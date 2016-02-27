//
//  CollectionViewAnimatedUpdater.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 27/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

protocol TTCollectionViewAnimatedUpdater {
    func collectionViewWillChangeContent(collectionView: UICollectionView)
    func collectionViewDidChangeContent(collectionView: UICollectionView)
    
    
    func collectionView(collectionView: UICollectionView, didUpdateItems indexPaths: [NSIndexPath])
    func collectionView(collectionView: UICollectionView, didDeleteItems indexPaths: [NSIndexPath])
    func collectionView(collectionView: UICollectionView, didInsertItems indexPaths: [NSIndexPath])
    
    func collectionView(collectionView: UICollectionView, didMoveItemsAtIndexPaths fromIndexPaths: [NSIndexPath], toIndexPaths: [NSIndexPath])

    func collectionView(collectionView: UICollectionView, didInsertSections sections: NSIndexSet)
    func collectionView(collectionView: UICollectionView, didDeleteSections sections: NSIndexSet)
    func collectionView(collectionView: UICollectionView, didUpdateSections sections: NSIndexSet)
}

class CollectionViewAnimatedUpdater: TTCollectionViewAnimatedUpdater {
    private var shouldReloadCollectionView = false
    private var batchOperation: [() -> Void]?
    
    func collectionViewWillChangeContent(collectionView: UICollectionView) {
        shouldReloadCollectionView = false
        assert(batchOperation == nil, "Updating block operation should be nil");
        batchOperation = []
    }
    
    func collectionViewDidChangeContent(collectionView: UICollectionView) {
        // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
        if (shouldReloadCollectionView) {
            collectionView.reloadData()
            self.batchOperation = nil
        } else {
            collectionView.performBatchUpdates({
                for block in self.batchOperation! {
                    block()
                }
                self.batchOperation = nil
                }, completion: nil)
        }
    }
    
    
    // MARK: - items operation
    func collectionView(collectionView: UICollectionView, didUpdateItems indexPaths: [NSIndexPath]) {
        batchOperation?.append({
            collectionView.reloadItemsAtIndexPaths(indexPaths)
        })
    }
    
    func collectionView(collectionView: UICollectionView, didDeleteItems indexPaths: [NSIndexPath]) {
        let indexPath = indexPaths.last!
        
        if collectionView.numberOfItemsInSection(indexPath.section) == 1 {
            shouldReloadCollectionView = true
        } else {
            batchOperation?.append({
                collectionView.deleteItemsAtIndexPaths(indexPaths)
            })
        }
    }
    
    func collectionView(collectionView: UICollectionView, didInsertItems indexPaths: [NSIndexPath]) {
        if collectionView.numberOfSections() > 0 {
            batchOperation?.append({
                collectionView.insertItemsAtIndexPaths(indexPaths)
            })
        } else {
            shouldReloadCollectionView = true
        }
    }
    
    func collectionView(collectionView: UICollectionView, didMoveItemsAtIndexPaths fromIndexPaths: [NSIndexPath], toIndexPaths: [NSIndexPath]) {
        batchOperation?.append({
            fromIndexPaths.enumerate().forEach({ (index, indexPath) in
                let toIndexPath = toIndexPaths[index]
                collectionView.moveItemAtIndexPath(indexPath, toIndexPath:toIndexPath)
            })
        })
    }
    
    func collectionView(collectionView: UICollectionView, didInsertSections sections: NSIndexSet) {
        batchOperation?.append({
            collectionView.insertSections(sections)
        })
    }
    
    func collectionView(collectionView: UICollectionView, didDeleteSections sections: NSIndexSet) {
        batchOperation?.append({
            collectionView.deleteSections(sections)
        })
    }
    
    func collectionView(collectionView: UICollectionView, didUpdateSections sections: NSIndexSet) {
        batchOperation?.append({
            collectionView.reloadSections(sections)
        })
    }
}