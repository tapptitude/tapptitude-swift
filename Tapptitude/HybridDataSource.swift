//
//  HybridDataSource.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 30/03/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

public protocol RequireNewSection {
    
}

public struct HybridItem {
    var element: Any
    var cellController: TTCollectionCellControllerProtocol
}

public protocol HybridCollectionCellController: TTCollectionCellControllerProtocol {
    func mapItem(item: Any) -> [Any]
}

extension HybridCollectionCellController {
    
}

public class HybridDataSource : SectionedDataSource<Any> {
    let multiCellController : HybridCellController!
    
    public init(content: [Any], multiCellController: HybridCellController) {
        self.multiCellController = multiCellController
        let controllers = multiCellController.cellControllers
        let translatedContent = HybridDataSource.transformContent(content, cellControllers: controllers)
        
        var items = [[Any]]()
        for subItem in translatedContent {
            items.append(subItem.map({$0 as Any}))
        }
        
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
    
    static func transformContent(content: [Any], cellControllers: [TTCollectionCellControllerProtocol]) -> [[HybridItem]] {
        var allItems = [[HybridItem]]()
        var items = [HybridItem]()
        
        let addNewSectionIfRequired = {(cellController: TTCollectionCellControllerProtocol) in
            if cellController is RequireNewSection {
                allItems.append(items)
                
                items = [HybridItem]()
                allItems.append(items)
            }
        }
        
        for item in content {
            for cellController in cellControllers  {
                if let hybridMapCellController = cellController as? HybridCollectionCellController {
                    let mappedItems = hybridMapCellController.mapItem(item)
                    if !mappedItems.isEmpty {
                        addNewSectionIfRequired(cellController)
                    }
                    
                    for newItem in  mappedItems {
                        if let hybridItem = newItem as? HybridItem {
                            items.append(hybridItem)
                        } else {
                            let hybridItem = HybridItem(element: newItem, cellController: cellController)
                            items.append(hybridItem)
                        }
                    }
                } else if cellController.acceptsContent(item) {
                    addNewSectionIfRequired(cellController)
                    let hybridItem = HybridItem(element: item, cellController: cellController)
                    items.append(hybridItem)
                }
            }
        }
        
        if !items.isEmpty {
            allItems.append(items)
        }
        
        return allItems
    }
    
    func transformContent(content:[Any]) -> [Any] {
        let items = HybridDataSource.transformContent(content, cellControllers: multiCellController.cellControllers)
        return items.map({$0 as Any})
    }
}

public class GroupCellController<ItemType>: MultiCollectionCellController, HybridCollectionCellController {
    public override init (_ cellControllers: [TTCollectionCellControllerProtocol]) {
        super.init(cellControllers)
    }
    
    public init (_ cellControllers: [TTCollectionCellControllerProtocol], acceptsContent: ((content: ItemType) -> Bool)) {
        super.init(cellControllers)
        self.acceptsContent = acceptsContent
    }
    
    public override func acceptsContent(content: Any) -> Bool {
        if let item = content as? ItemType {
            return acceptsContent(item)
        } else {
            return false
        }
    }
    
    public func acceptsContent(content: ItemType) -> Bool {
        if let acccepts = acceptsContent {
            return acccepts(content: content)
        } else {
            return true
        }
    }
    
    public var acceptsContent: ((content: ItemType) -> Bool)?
    
    public func mapItem(item: Any) -> [Any] {
        if acceptsContent(item) {
            var items = [Any]()
            
            for cellController in cellControllers {
                if let hybridMapCellController = cellController as? HybridCollectionCellController {
                    let mappedItems = hybridMapCellController.mapItem(item)
                    
                    for newItem in  mappedItems {
                        let hybridItem = HybridItem(element: newItem, cellController: cellController)
                        items.append(hybridItem)
                    }
                } else if cellController.acceptsContent(item) {
                    let hybridItem = HybridItem(element: item, cellController: cellController)
                    items.append(hybridItem)
                }
            }
            
            return items
        } else {
            return []
        }
    }
}

public class HybridCellController : MultiCollectionCellController {
    
    override public func controllerForContent(content: Any) -> TTCollectionCellControllerProtocol? {
        return (content is HybridItem) ? self : super.controllerForContent(content)
    }
    
    override public func acceptsContent(content: Any) -> Bool {
        return controllerForContent(content) != nil
    }
    
    override public func classToInstantiateCell(for content: Any) -> AnyClass? {
        if let content = content as? HybridItem {
            return content.cellController.classToInstantiateCell(for: content.element)
        } else {
            return super.classToInstantiateCell(for: content)
        }
    }
    
    override public func nibToInstantiateCell(for content: Any) -> UINib? {
        if let content = content as? HybridItem {
            return content.cellController.nibToInstantiateCell(for: content.element)
        } else {
            return super.nibToInstantiateCell(for: content)
        }
    }
    
    override public func reuseIdentifier(for content: Any) -> String {
        if let content = content as? HybridItem {
            return content.cellController.reuseIdentifier(for: content.element)
        } else {
            return super.reuseIdentifier(for: content)
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
    
    override public func cellSize(for content: Any, collectionView: UICollectionView) -> CGSize {
        if let content = content as? HybridItem {
            return content.cellController.cellSize(for: content.element, collectionView: collectionView)
        } else {
            return super.cellSize(for: content, collectionView: collectionView)
        }
    }
    
    override public func sectionInset(for content: Any, collectionView: UICollectionView) -> UIEdgeInsets {
        if let content = content as? HybridItem {
            return content.cellController.sectionInset(for: content.element, collectionView: collectionView)
        } else {
            return super.sectionInset(for: content, collectionView: collectionView)
        }
    }
    
    override public func minimumLineSpacing(for content: Any, collectionView: UICollectionView) -> CGFloat {
        if let content = content as? HybridItem {
            return content.cellController.minimumLineSpacing(for: content.element, collectionView: collectionView)
        } else {
            return super.minimumLineSpacing(for: content, collectionView: collectionView)
        }
    }
    
    override public func minimumInteritemSpacing(for content: Any, collectionView: UICollectionView) -> CGFloat {
        if let content = content as? HybridItem {
            return content.cellController.minimumInteritemSpacing(for: content.element, collectionView: collectionView)
        } else {
            return super.minimumInteritemSpacing(for: content, collectionView: collectionView)
        }
    }
}