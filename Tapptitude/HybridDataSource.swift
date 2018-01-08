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
    public var element: Any
    public var cellController: TTAnyCollectionCellController
}

public protocol HybridCollectionCellController: TTAnyCollectionCellController {
    func mapItem(_ item: Any) -> [Any]
}

extension HybridCollectionCellController {
    
}

open class HybridDataSource : SectionedDataSource<Any> {
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
    
    public required convenience init(arrayLiteral elements: Element...) {
        abort()
    }
    
    open override func dataFeed(_ dataFeed: TTDataFeed?, didLoadResult result: Result<[Any]>, forState: FeedState.Load) {
        var result = result
        if let content = result.value {
            result = .success(transformContent(content))
        }
        super.dataFeed(dataFeed, didLoadResult: result, forState: forState)
    }
    
    static func transformContent(_ content: [Any], cellControllers: [TTAnyCollectionCellController]) -> [[HybridItem]] {
        var allItems = [[HybridItem]]()
        var items = [HybridItem]()
        
        let addNewSectionIfRequired = {(cellController: TTAnyCollectionCellController) in
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
    
    func transformContent(_ content:[Any]) -> [Any] {
        let items = HybridDataSource.transformContent(content, cellControllers: multiCellController.cellControllers)
        return items.map({$0 as Any})
    }
}

open class GroupCellController<ItemType>: MultiCollectionCellController, HybridCollectionCellController {
    public override init (_ cellControllers: [TTAnyCollectionCellController]) {
        super.init(cellControllers)
    }
    
    public init (_ cellControllers: [TTAnyCollectionCellController], acceptsContent: @escaping ((_ content: ItemType) -> Bool)) {
        super.init(cellControllers)
        self.acceptsContent = acceptsContent
    }
    
    public convenience required init(arrayLiteral elements: TTAnyCollectionCellController...) {
        self.init(elements.map({ $0 }))
    }
    
    open override func acceptsContent(_ content: Any) -> Bool {
        if let item = content as? ItemType {
            return acceptsContent(item)
        } else {
            return super.acceptsContent(content)
        }
    }
    
    open func acceptsContent(_ content: ItemType) -> Bool {
        return acceptsContent?(content) ?? true
    }
    
    open var acceptsContent: ((_ content: ItemType) -> Bool)?
    
    open func mapItem(_ item: Any) -> [Any] {
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

open class HybridCellController : MultiCollectionCellController {
    public override init (_ cellControllers: [TTAnyCollectionCellController]) {
        super.init(cellControllers)
    }
    
    public override init (_ cellControllers: TTAnyCollectionCellController...) {
        super.init(cellControllers)
    }
    
    override open func controllerForContent(_ content: Any) -> TTAnyCollectionCellController? {
        return (content is HybridItem) ? self : super.controllerForContent(content)
    }
    
    override open func acceptsContent(_ content: Any) -> Bool {
        return controllerForContent(content) != nil
    }
    
    override open func classToInstantiateCell(for content: Any) -> AnyClass? {
        if let content = content as? HybridItem {
            return content.cellController.classToInstantiateCell(for: content.element)
        } else {
            return super.classToInstantiateCell(for: content)
        }
    }
    
    override open func nibToInstantiateCell(for content: Any) -> UINib? {
        if let content = content as? HybridItem {
            return content.cellController.nibToInstantiateCell(for: content.element)
        } else {
            return super.nibToInstantiateCell(for: content)
        }
    }
    
    override open func reuseIdentifier(for content: Any) -> String {
        if let content = content as? HybridItem {
            return content.cellController.reuseIdentifier(for: content.element)
        } else {
            return super.reuseIdentifier(for: content)
        }
    }
    
    override open func configureCell(_ cell: UICollectionViewCell, for content: Any, at indexPath: IndexPath) {
        if let content = content as? HybridItem {
            return content.cellController.configureCell(cell, for: content.element, at: indexPath)
        } else {
            return super.configureCell(cell, for: content, at: indexPath)
        }
    }
    
    override open func didSelectContent(_ content: Any, at indexPath: IndexPath, in collectionView: UICollectionView) {
        if let content = content as? HybridItem {
            return content.cellController.didSelectContent(content.element, at: indexPath, in: collectionView)
        } else {
            return super.didSelectContent(content, at: indexPath, in: collectionView)
        }
    }
    
    override open func cellSize(for content: Any, in collectionView: UICollectionView) -> CGSize {
        if let content = content as? HybridItem {
            return content.cellController.cellSize(for: content.element, in: collectionView)
        } else {
            return super.cellSize(for: content, in: collectionView)
        }
    }
    
    override open func sectionInset(for content: Any, in collectionView: UICollectionView) -> UIEdgeInsets {
        if let content = content as? HybridItem {
            return content.cellController.sectionInset(for: content.element, in: collectionView)
        } else {
            return super.sectionInset(for: content, in: collectionView)
        }
    }
    
    override open func minimumLineSpacing(for content: Any, in collectionView: UICollectionView) -> CGFloat {
        if let content = content as? HybridItem {
            return content.cellController.minimumLineSpacing(for: content.element, in: collectionView)
        } else {
            return super.minimumLineSpacing(for: content, in: collectionView)
        }
    }
    
    override open func minimumInteritemSpacing(for content: Any, in collectionView: UICollectionView) -> CGFloat {
        if let content = content as? HybridItem {
            return content.cellController.minimumInteritemSpacing(for: content.element, in: collectionView)
        } else {
            return super.minimumInteritemSpacing(for: content, in: collectionView)
        }
    }
}
