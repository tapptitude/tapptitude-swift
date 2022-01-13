//
//  BatchCollectionViewUpdater.swift
//  Tapptitude
//
//  Created by Ion Toderasco on 11/11/2018.
//  Copyright © 2018 Tapptitude. All rights reserved.
//

import Foundation
import UIKit

class BatchCollectionViewUpdater: TTCollectionViewUpdater, TTTableViewUpdater {
    
    var batchOperation: [() -> Void]? = []
    
    var animatesUpdates: Bool = true
    var animationConfig: TTRowAnimationConfig

    init(animatesUpdates: Bool, animationConfig: TTRowAnimationConfig = TTRowAnimationConfig()) {
        self.animatesUpdates = animatesUpdates
        self.animationConfig = animationConfig
    }
    
    open func perfomBatchUpdates(_ updates: (() -> Void), animationCompletion:(()->Void)?) {
        
    }
    
    //MARK:- Collection View
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
    
    
    //MARK:- Table View
    func tableViewWillChangeContent(_ tableView: UITableView) {
    }
    
    func tableViewDidChangeContent(_ tableView: UITableView, animationCompletion: (() -> Void)?) {
    }
    
    // MARK: - items operation
    func tableView(_ tableView: UITableView, didUpdateItemsAt indexPaths: [IndexPath]) {
        batchOperation?.append({[weak self] in
            tableView.reloadRows(at: indexPaths, with: self?.animationConfig.itemsReload ?? .automatic)
        })
    }
    
    func tableView(_ tableView: UITableView, didDeleteItemsAt indexPaths: [IndexPath]) {
        batchOperation?.append({[weak self] in
            tableView.deleteRows(at: indexPaths, with: self?.animationConfig.itemsDelete ?? .automatic)
        })
    }
    
    func tableView(_ tableView: UITableView, didInsertItemsAt indexPaths: [IndexPath]) {
        batchOperation?.append({[weak self] in
            tableView.insertRows(at: indexPaths, with: self?.animationConfig.itemsInsert ?? .automatic)
        })
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
        batchOperation?.append({[weak self] in
            tableView.insertSections(sections, with: self?.animationConfig.sectionsInsert ?? .automatic)
        })
    }
    
    func tableView(_ tableView: UITableView, didDeleteSections sections: IndexSet) {
        batchOperation?.append({[weak self] in
            tableView.deleteSections(sections, with: self?.animationConfig.sectionsDelete ?? .automatic)
        })
    }
    
    func tableView(_ tableView: UITableView, didUpdateSections sections: IndexSet) {
        batchOperation?.append({[weak self] in
            tableView.reloadSections(sections, with: self?.animationConfig.sectionsReload ?? .automatic)
        })
    }
}
