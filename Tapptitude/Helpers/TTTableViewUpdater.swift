//
//  TTTableViewUpdater.swift
//  Tapptitude
//
//  Created by Ion Toderasco on 11/11/2018.
//  Copyright © 2018 Tapptitude. All rights reserved.
//

import UIKit

public struct TTRowAnimationConfig {
    let itemsReload = UITableView.RowAnimation.automatic
    let itemsDelete = UITableView.RowAnimation.automatic
    let itemsInsert = UITableView.RowAnimation.automatic
    let sectionsReload = UITableView.RowAnimation.automatic
    let sectionsDelete = UITableView.RowAnimation.automatic
    let sectionsInsert = UITableView.RowAnimation.automatic
}

protocol TTTableViewUpdater {
    var animatesUpdates: Bool { get set }
    var animationConfig: TTRowAnimationConfig { get set }
    
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

public class TableViewUpdater: TTTableViewUpdater {
        
    fileprivate var shouldReloadCollectionView = false
    fileprivate var batchOperation: [() -> Void]?
    
    var animatesUpdates: Bool = true
    var animationConfig: TTRowAnimationConfig
    
    init(animatesUpdates: Bool, animationConfig: TTRowAnimationConfig = TTRowAnimationConfig()) {
        self.animatesUpdates = animatesUpdates
        self.animationConfig = animationConfig
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
                    tableView.beginUpdates()
                    self.batchOperation?.forEach{ $0() }
                    tableView.endUpdates()
                    animationCompletion?()
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
        batchOperation?.append({[weak self] in
            tableView.reloadRows(at: indexPaths, with: self?.animationConfig.itemsReload ?? .automatic)
        })
    }
    
    func tableView(_ tableView: UITableView, didDeleteItemsAt indexPaths: [IndexPath]) {
        guard let indexPath = indexPaths.last else {
            return
        }
        
        if tableView.numberOfRows(inSection: indexPath.section) == 1 {
            shouldReloadCollectionView = true
        } else {
            batchOperation?.append({[weak self] in
                tableView.deleteRows(at: indexPaths, with: self?.animationConfig.itemsDelete ?? .automatic)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didInsertItemsAt indexPaths: [IndexPath]) {
        if tableView.numberOfSections > 0 {
            batchOperation?.append({[weak self] in
                tableView.insertRows(at: indexPaths, with: self?.animationConfig.itemsInsert ?? .automatic)
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
