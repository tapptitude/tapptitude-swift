//
//  CollectionViewAnimatedUpdater.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 27/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

protocol TTCollectionViewUpdater {
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

class CollectionViewUpdater: TTCollectionViewUpdater {
    fileprivate var shouldReloadCollectionView = false
    fileprivate var batchOperation: [() -> Void]?
    
    var animatesUpdates: Bool = true
    
    init(animatesUpdates: Bool) {
        self.animatesUpdates = animatesUpdates
    }
    
    func collectionViewWillChangeContent(_ collectionView: UICollectionView) {
        shouldReloadCollectionView = false
        assert(batchOperation == nil, "Updating block operation should be nil");
        batchOperation = []
    }
    
    func collectionViewDidChangeContent(_ collectionView: UICollectionView, animationCompletion: (() -> Void)?) {
        defer {
            self.batchOperation = nil
        }
        
        // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
        let noChanges = (batchOperation == nil || batchOperation?.isEmpty == true)
        
        if (shouldReloadCollectionView || noChanges) {
            collectionView.reloadData()
            animationCompletion?()
        } else {
            if animatesUpdates {
                collectionView.performBatchUpdates({
                    self.batchOperation?.forEach{ $0() }
                }, completion: { finished in
                    animationCompletion?()
                })
            } else {
                UIView.performWithoutAnimation {
                    self.batchOperation?.forEach{ $0() }
                    animationCompletion?()
                }
            }
        }
    }
    
    
    // MARK: - items operation
    func collectionView(_ collectionView: UICollectionView, didUpdateItemsAt indexPaths: [IndexPath]) {
        batchOperation?.append({
            collectionView.reloadItems(at: indexPaths)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeleteItemsAt indexPaths: [IndexPath]) {
        guard let indexPath = indexPaths.last else {
            return
        }
        
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

class BatchCollectionViewUpdater: TTCollectionViewUpdater {
    
    var batchOperation: [() -> Void]? = []
    
    var animatesUpdates: Bool = true
    
    init(animatesUpdates: Bool) {
        self.animatesUpdates = animatesUpdates
    }
    
    open func perfomBatchUpdates(_ updates: (() -> Void), animationCompletion:(()->Void)?) {
        
    }
    
    func collectionViewWillChangeContent(_ collectionView: UICollectionView) {
    }
    
    func collectionViewDidChangeContent(_ collectionView: UICollectionView, animationCompletion: (() -> Void)?) {
    }
    
    // MARK: - items operation
    func collectionView(_ collectionView: UICollectionView, didUpdateItemsAt indexPaths: [IndexPath]) {
        batchOperation?.append({
            collectionView.reloadItems(at: indexPaths)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeleteItemsAt indexPaths: [IndexPath]) {
        batchOperation?.append({
            collectionView.deleteItems(at: indexPaths)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didInsertItemsAt indexPaths: [IndexPath]) {
        batchOperation?.append({
            collectionView.insertItems(at: indexPaths)
        })
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
