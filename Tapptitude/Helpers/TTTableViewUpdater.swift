//
//  TTTableViewUpdater.swift
//  Tapptitude
//
//  Created by Ion Toderasco on 11/11/2018.
//  Copyright © 2018 Tapptitude. All rights reserved.
//

import UIKit

protocol TTTableViewUpdater {
    
    func tableViewWillChangeContent(_ tableView: UITableView)
    func tableViewDidChangeContent(_ tableView: UITableView, animationCompletion: (() -> Void)?)
    
    
    func tableView(_ tableView: UITableView, didUpdateItemsAt indexPaths: [IndexPath])
    func tableView(_ tableView: UITableView, didDeleteItemsAt indexPaths: [IndexPath])
    func tableView(_ tableView: UITableView, didInsertItemsAt indexPaths: [IndexPath])
    
    func tableView(_ tableView: UITableView, didMoveItemsFrom fromIndexPaths: [IndexPath], to toIndexPaths: [IndexPath])
    
    func tableView(_ tableView: UITableView, didInsertSections sections: IndexSet)
    func tableView(_ tableView: UITableView, didDeleteSections sections: IndexSet)
    func tableView(_ tableView: UITableView, didUpdateSections sections: IndexSet)
}

class TableViewUpdater: TTTableViewUpdater {
    
    fileprivate var shouldReloadCollectionView = false
    fileprivate var batchOperation: [() -> Void]?
    
    var animatesUpdates: Bool = true
    
    init(animatesUpdates: Bool) {
        self.animatesUpdates = animatesUpdates
    }
    
    func tableViewWillChangeContent(_ tableView: UITableView) {
        shouldReloadCollectionView = false
        assert(batchOperation == nil, "Updating block operation should be nil");
        batchOperation = []
    }
    
    func tableViewDidChangeContent(_ tableView: UITableView, animationCompletion: (() -> Void)?) {
        defer {
            self.batchOperation = nil
        }
        
        // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
        let noChanges = (batchOperation == nil || batchOperation?.isEmpty == true)
        
        if (shouldReloadCollectionView || noChanges) {
            tableView.reloadData()
            animationCompletion?()
        } else {
            if animatesUpdates {
                if #available(iOS 11.0, *) {
                    tableView.performBatchUpdates({
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
            } else {
                UIView.performWithoutAnimation {
                    self.batchOperation?.forEach{ $0() }
                    animationCompletion?()
                }
            }
        }
    }
    
    
    // MARK: - items operation
    func tableView(_ tableView: UITableView, didUpdateItemsAt indexPaths: [IndexPath]) {
        batchOperation?.append({
            tableView.reloadRows(at: indexPaths, with: .automatic)
        })
    }
    
    func tableView(_ tableView: UITableView, didDeleteItemsAt indexPaths: [IndexPath]) {
        guard let indexPath = indexPaths.last else {
            return
        }
        
        if tableView.numberOfRows(inSection: indexPath.section) == 1 {
            shouldReloadCollectionView = true
        } else {
            batchOperation?.append({
                tableView.deleteRows(at: indexPaths, with: .automatic)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didInsertItemsAt indexPaths: [IndexPath]) {
        if tableView.numberOfSections > 0 {
            batchOperation?.append({
                tableView.insertRows(at: indexPaths, with: .automatic)
            })
        } else {
            shouldReloadCollectionView = true
        }
    }
    
    func tableView(_ tableView: UITableView, didMoveItemsFrom fromIndexPaths: [IndexPath], to toIndexPaths: [IndexPath]) {
        batchOperation?.append({
            fromIndexPaths.enumerated().forEach({ (index, indexPath) in
                let toIndexPath = toIndexPaths[index]
                tableView.moveRow(at: indexPath, to: toIndexPath)
            })
        })
    }
    
    func tableView(_ tableView: UITableView, didInsertSections sections: IndexSet) {
        batchOperation?.append({
            tableView.insertSections(sections, with: .automatic)
        })
    }
    
    func tableView(_ tableView: UITableView, didDeleteSections sections: IndexSet) {
        batchOperation?.append({
            tableView.deleteSections(sections, with: .automatic)
        })
    }
    
    func tableView(_ tableView: UITableView, didUpdateSections sections: IndexSet) {
        batchOperation?.append({
            tableView.reloadSections(sections, with: .automatic)
        })
    }
}
