//
//  MultiCollectionCellController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 21/03/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

public class MultiCollectionCellController {
    public init (_ cellControllers: [TTCollectionCellControllerProtocol]) {
        self.cellControllers = cellControllers
    }
    
    public var cellControllers: [TTCollectionCellControllerProtocol] = [] {
        willSet {
            for var cellController in cellControllers {
                cellController.parentViewController = nil
            }
        }
        
        didSet {
            for var cellController in cellControllers {
                cellController.parentViewController = parentViewController
            }
        }
    }
    
    private var previousCellController: TTCollectionCellControllerProtocol?
    
    
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
}

extension MultiCollectionCellController: TTCollectionCellControllerProtocol {
    public func acceptsContent(content: Any) -> Bool {
        return controllerForContent(content) != nil
    }
    
    public func classToInstantiateCellForContent(content: Any) -> AnyClass? {
        return controllerForContent(content)?.classToInstantiateCellForContent(content)
    }
    
    public func nibToInstantiateCellForContent(content: Any) -> UINib? {
        return controllerForContent(content)?.nibToInstantiateCellForContent(content)
    }
    
    public func reuseIdentifierForContent(content: Any) -> String {
        return controllerForContent(content)!.reuseIdentifierForContent(content)
    }
    
    public func configureCell(cell: UICollectionViewCell, forContent content: Any, indexPath: NSIndexPath) {
        controllerForContent(content)!.configureCell(cell, forContent: content, indexPath: indexPath)
    }
    
    public func didSelectContent(content: Any, indexPath: NSIndexPath, collectionView: UICollectionView) {
        controllerForContent(content)!.didSelectContent(content, indexPath: indexPath, collectionView: collectionView)
    }
    
    public func cellSizeForContent(content: Any, collectionView: UICollectionView) -> CGSize {
        return controllerForContent(content)!.cellSizeForContent(content, collectionView: collectionView)
    }
    
    public func sectionInsetForContent(content: Any, collectionView: UICollectionView) -> UIEdgeInsets {
        return controllerForContent(content)!.sectionInsetForContent(content, collectionView: collectionView)
    }
    public func minimumLineSpacingForContent(content: Any, collectionView: UICollectionView) -> CGFloat {
        return controllerForContent(content)!.minimumLineSpacingForContent(content, collectionView: collectionView)
    }
    public func minimumInteritemSpacingForContent(content: Any, collectionView: UICollectionView) -> CGFloat {
        return controllerForContent(content)!.minimumInteritemSpacingForContent(content, collectionView: collectionView)
    }
}