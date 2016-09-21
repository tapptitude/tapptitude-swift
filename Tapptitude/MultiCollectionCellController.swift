//
//  MultiCollectionCellController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 21/03/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

public class MultiCollectionCellController: TTCollectionCellControllerProtocol {
    public init (_ cellControllers: [TTCollectionCellControllerProtocol]) {
        self.cellControllers = cellControllers
    }
    
    public var cellControllers: [TTCollectionCellControllerProtocol] = [] {
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
    
    private var previousCellController: TTCollectionCellControllerProtocol? // TODO: check if we should use weak
    
    
    public func controllerForContent(content: Any) -> TTCollectionCellControllerProtocol? {
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
    public weak var parentViewController: UIViewController? {
        didSet {
            for var cellController in cellControllers {
                cellController.parentViewController = parentViewController
            }
        }
    }
    
    public var cellSize : CGSize {
        return CGSizeZero
    }
    
    public var sectionInset : UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    public var minimumLineSpacing : CGFloat {
        return 0.0
    }
    public var minimumInteritemSpacing : CGFloat {
        return 0.0
    }
//}
//
//extension MultiCollectionCellController: TTCollectionCellControllerProtocol {
    public func acceptsContent(content: Any) -> Bool {
        return controllerForContent(content) != nil
    }
    
    public func classToInstantiateCell(for content: Any) -> AnyClass? {
        return controllerForContent(content)?.classToInstantiateCell(for: content)
    }
    
    public func nibToInstantiateCell(for content: Any) -> UINib? {
        return controllerForContent(content)?.nibToInstantiateCell(for: content)
    }
    
    public func reuseIdentifier(for content: Any) -> String {
        return controllerForContent(content)!.reuseIdentifier(for: content)
    }
    
    public func configureCell(cell: UICollectionViewCell, for content: Any, at indexPath: NSIndexPath) {
        controllerForContent(content)!.configureCell(cell, for: content, at: indexPath)
    }
    
    public func didSelectContent(content: Any, at indexPath: NSIndexPath, in collectionView: UICollectionView) {
        controllerForContent(content)!.didSelectContent(content, at: indexPath, in: collectionView)
    }
    
    public func cellSize(for content: Any, in collectionView: UICollectionView) -> CGSize {
        return controllerForContent(content)!.cellSize(for: content, in: collectionView)
    }
    
    public func sectionInset(for content: Any, in collectionView: UICollectionView) -> UIEdgeInsets {
        return controllerForContent(content)!.sectionInset(for: content, in: collectionView)
    }
    public func minimumLineSpacing(for content: Any, in collectionView: UICollectionView) -> CGFloat {
        return controllerForContent(content)!.minimumLineSpacing(for: content, in: collectionView)
    }
    public func minimumInteritemSpacing(for content: Any, in collectionView: UICollectionView) -> CGFloat {
        return controllerForContent(content)!.minimumInteritemSpacing(for: content, in: collectionView)
    }
}