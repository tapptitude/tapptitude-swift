//
//  CollectionViewAnimatedUpdater.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 27/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

protocol TTCollectionViewAnimatedUpdater {
    func collectionViewWillChangeContent(_ collectionView: UICollectionView)
    func collectionViewDidChangeContent(_ collectionView: UICollectionView, animationCompletion: (() -> Void)?)
    
    
    func collectionView(_ collectionView: UICollectionView, didUpdateItemsAt indexPaths: [IndexPath])
    func collectionView(_ collectionView: UICollectionView, didDeleteItemsAt indexPaths: [IndexPath])
    func collectionView(_ collectionView: UICollectionView, didInsertItemsAt indexPaths: [IndexPath])
    
    func collectionView(_ collectionView: UICollectionView, didMoveItemsFrom fromIndexPaths: [IndexPath], to toIndexPaths: [IndexPath])

    func collectionView(_ collectionView: UICollectionView, didInsertSections sections: IndexSet)
    func collectionView(_ collectionView: UICollectionView, didDeleteSections sections: IndexSet)
    func collectionView(_ collectionView: UICollectionView, didUpdateSections sections: IndexSet)
}

class CollectionViewAnimatedUpdater: TTCollectionViewAnimatedUpdater {
    fileprivate var shouldReloadCollectionView = false
    fileprivate var batchOperation: [() -> Void]?
    
    func collectionViewWillChangeContent(_ collectionView: UICollectionView) {
        shouldReloadCollectionView = false
        assert(batchOperation == nil, "Updating block operation should be nil");
        batchOperation = []
    }
    
    func collectionViewDidChangeContent(_ collectionView: UICollectionView, animationCompletion: (() -> Void)?) {
        // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
        if (shouldReloadCollectionView) {
            collectionView.reloadData()
            animationCompletion?()
            self.batchOperation = nil
        } else {
            collectionView.performBatchUpdates({
                for block in self.batchOperation! {
                    block()
                }
                self.batchOperation = nil
            }, completion: { finished in
                animationCompletion?()
            })
        }
    }
    
    
    // MARK: - items operation
    func collectionView(_ collectionView: UICollectionView, didUpdateItemsAt indexPaths: [IndexPath]) {
        batchOperation?.append({
            collectionView.reloadItems(at: indexPaths)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeleteItemsAt indexPaths: [IndexPath]) {
        let indexPath = indexPaths.last!
        
        if collectionView.numberOfItems(inSection: indexPath.section) == 1 {
            shouldReloadCollectionView = true
        } else {
            batchOperation?.append({
                collectionView.deleteItems(at: indexPaths)
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didInsertItemsAt indexPaths: [IndexPath]) {
        if collectionView.numberOfSections > 0 {
            batchOperation?.append({
                collectionView.insertItems(at: indexPaths)
            })
        } else {
            shouldReloadCollectionView = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didMoveItemsFrom fromIndexPaths: [IndexPath], to toIndexPaths: [IndexPath]) {
        batchOperation?.append({
            fromIndexPaths.enumerated().forEach({ (index, indexPath) in
                let toIndexPath = toIndexPaths[index]
                collectionView.moveItem(at: indexPath, to:toIndexPath)
            })
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didInsertSections sections: IndexSet) {
        batchOperation?.append({
            collectionView.insertSections(sections)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeleteSections sections: IndexSet) {
        batchOperation?.append({
            collectionView.deleteSections(sections)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateSections sections: IndexSet) {
        batchOperation?.append({
            collectionView.reloadSections(sections)
        })
    }
}
