//
//  HybridDataSource.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 30/03/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

struct HybridItem {
    var element: Any
    var cellController: TTCollectionCellControllerProtocol
}

public protocol HybridCollectionCellController: TTCollectionCellControllerProtocol {
    func mapItem(item: Any) -> [Any]
}

public class HybridDataSource : DataSource {
    let multiCellController : HybridCellController!
    
    public init(content: [Any], multiCellController: HybridCellController) {
        self.multiCellController = multiCellController
        let controllers = multiCellController.cellControllers
        let translatedContent = HybridDataSource.transformContent(content, cellControllers: controllers)
        let items = translatedContent.map({$0 as Any})
        
        super.init(items)
    }
    
    override public func dataFeed(dataFeed: TTDataFeed?, didLoadMoreContent content: [Any]?) {
        if let content = content {
            super.dataFeed(dataFeed, didLoadMoreContent: transformContent(content))
        } else {
            super.dataFeed(dataFeed, didLoadMoreContent: content)
        }
        
    }
    
    override public func dataFeed(dataFeed: TTDataFeed?, didReloadContent content: [Any]?) {
        if let content = content {
            super.dataFeed(dataFeed, didReloadContent: transformContent(content))
        } else {
            super.dataFeed(dataFeed, didReloadContent: content)
        }
    }
    
    static func transformContent(content: [Any], cellControllers: [TTCollectionCellControllerProtocol]) -> [HybridItem] {
        var items = [HybridItem]()
        
        for item in content {
            for cellController in cellControllers  {
                if cellController.acceptsContent(item) {
                    let hybridItem = HybridItem(element: item, cellController: cellController)
                    items.append(hybridItem)
                } else if let hybridMapCellController = cellController as? HybridCollectionCellController {
                    for newItem in hybridMapCellController.mapItem(item) {
                        let hybridItem = HybridItem(element: newItem, cellController: cellController)
                        items.append(hybridItem)
                    }
                }
            }
        }
        
        return items
    }
    
    func transformContent(content:[Any]) -> [Any] {
        let items = HybridDataSource.transformContent(content, cellControllers: multiCellController.cellControllers)
        return items.map({$0 as Any})
    }
}

public class HybridCellController : MultiCollectionCellController {
    
    override public func controllerForContent(content: Any) -> TTCollectionCellControllerProtocol? {
        return (content is HybridItem) ? self : super.controllerForContent(content)
    }
    
    override public func acceptsContent(content: Any) -> Bool {
        return controllerForContent(content) != nil
    }
    
    override public func classToInstantiateCellForContent(content: Any) -> AnyClass? {
        if let content = content as? HybridItem {
            return content.cellController.classToInstantiateCellForContent(content.element)
        } else {
            return super.classToInstantiateCellForContent(content)
        }
    }
    
    override public func nibToInstantiateCellForContent(content: Any) -> UINib? {
        if let content = content as? HybridItem {
            return content.cellController.nibToInstantiateCellForContent(content.element)
        } else {
            return super.nibToInstantiateCellForContent(content)
        }
    }
    
    override public func reuseIdentifierForContent(content: Any) -> String {
        if let content = content as? HybridItem {
            return content.cellController.reuseIdentifierForContent(content.element)
        } else {
            return super.reuseIdentifierForContent(content)
        }
    }
    
    override public func configureCell(cell: UICollectionViewCell, forContent content: Any, indexPath: NSIndexPath) {
        if let content = content as? HybridItem {
            return content.cellController.configureCell(cell, forContent: content.element, indexPath: indexPath)
        } else {
            return super.configureCell(cell, forContent: content, indexPath: indexPath)
        }
    }
    
    override public func didSelectContent(content: Any, indexPath: NSIndexPath, collectionView: UICollectionView) {
        if let content = content as? HybridItem {
            return content.cellController.didSelectContent(content.element, indexPath: indexPath, collectionView: collectionView)
        } else {
            return super.didSelectContent(content, indexPath: indexPath, collectionView: collectionView)
        }
    }
    
    override public func cellSizeForContent(content: Any, collectionView: UICollectionView) -> CGSize {
        if let content = content as? HybridItem {
            return content.cellController.cellSizeForContent(content.element, collectionView: collectionView)
        } else {
            return super.cellSizeForContent(content, collectionView: collectionView)
        }
    }
    
    override public func sectionInsetForContent(content: Any, collectionView: UICollectionView) -> UIEdgeInsets {
        if let content = content as? HybridItem {
            return content.cellController.sectionInsetForContent(content.element, collectionView: collectionView)
        } else {
            return super.sectionInsetForContent(content, collectionView: collectionView)
        }
    }
    
    override public func minimumLineSpacingForContent(content: Any, collectionView: UICollectionView) -> CGFloat {
        if let content = content as? HybridItem {
            return content.cellController.minimumLineSpacingForContent(content.element, collectionView: collectionView)
        } else {
            return super.minimumLineSpacingForContent(content, collectionView: collectionView)
        }
    }
    
    override public func minimumInteritemSpacingForContent(content: Any, collectionView: UICollectionView) -> CGFloat {
        if let content = content as? HybridItem {
            return content.cellController.minimumInteritemSpacingForContent(content.element, collectionView: collectionView)
        } else {
            return super.minimumInteritemSpacingForContent(content, collectionView: collectionView)
        }
    }
}