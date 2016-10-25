//
//  MultiCollectionCellController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 21/03/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

open class MultiCollectionCellController: TTCollectionCellControllerProtocol {
    public init (_ cellControllers: [TTCollectionCellControllerProtocol]) {
        self.cellControllers = cellControllers
    }
    
    open var cellControllers: [TTCollectionCellControllerProtocol] = [] {
        willSet {
            for var cellController in cellControllers {
                cellController.parentViewController = nil
            }
            previousCellController = nil
        }
        
        didSet {
            for var cellController in cellControllers {
                cellController.parentViewController = parentViewController
            }
        }
    }
    
    fileprivate var previousCellController: TTCollectionCellControllerProtocol? // TODO: check if we should use weak
    
    
    open func controllerForContent(_ content: Any) -> TTCollectionCellControllerProtocol? {
        if previousCellController?.acceptsContent(content) == true { // for performance update
            return previousCellController
        }
        
        for cellController in cellControllers {
            if cellController.acceptsContent(content) == true {
                previousCellController = cellController
                return cellController
            }
        }
        
        return nil
    }
    
    // Stored properties for TTCollectionCellControllerProtocol
    open weak var parentViewController: UIViewController? {
        didSet {
            for var cellController in cellControllers {
                cellController.parentViewController = parentViewController
            }
        }
    }
    
    open var cellSize : CGSize {
        return CGSize.zero
    }
    
    open var sectionInset : UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    open var minimumLineSpacing : CGFloat {
        return 0.0
    }
    open var minimumInteritemSpacing : CGFloat {
        return 0.0
    }
//}
//
//extension MultiCollectionCellController: TTCollectionCellControllerProtocol {
    open func acceptsContent(_ content: Any) -> Bool {
        return controllerForContent(content) != nil
    }
    
    open func classToInstantiateCell(for content: Any) -> AnyClass? {
        return controllerForContent(content)?.classToInstantiateCell(for: content)
    }
    
    open func nibToInstantiateCell(for content: Any) -> UINib? {
        return controllerForContent(content)?.nibToInstantiateCell(for: content)
    }
    
    open func reuseIdentifier(for content: Any) -> String {
        return controllerForContent(content)!.reuseIdentifier(for: content)
    }
    
    open func configureCell(_ cell: UICollectionViewCell, for content: Any, at indexPath: IndexPath) {
        controllerForContent(content)!.configureCell(cell, for: content, at: indexPath)
    }
    
    open func didSelectContent(_ content: Any, at indexPath: IndexPath, in collectionView: UICollectionView) {
        controllerForContent(content)!.didSelectContent(content, at: indexPath, in: collectionView)
    }
    
    open func cellSize(for content: Any, in collectionView: UICollectionView) -> CGSize {
        return controllerForContent(content)!.cellSize(for: content, in: collectionView)
    }
    
    open func sectionInset(for content: Any, in collectionView: UICollectionView) -> UIEdgeInsets {
        return controllerForContent(content)!.sectionInset(for: content, in: collectionView)
    }
    open func minimumLineSpacing(for content: Any, in collectionView: UICollectionView) -> CGFloat {
        return controllerForContent(content)!.minimumLineSpacing(for: content, in: collectionView)
    }
    open func minimumInteritemSpacing(for content: Any, in collectionView: UICollectionView) -> CGFloat {
        return controllerForContent(content)!.minimumInteritemSpacing(for: content, in: collectionView)
    }
}
