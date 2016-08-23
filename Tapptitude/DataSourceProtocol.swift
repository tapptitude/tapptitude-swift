//
//  DataSourceProtocol.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public protocol TTDataSource : TTDataFeedDelegate, CustomStringConvertible {
    
    var content : [Any] { get }
    func hasContent() -> Bool
    func numberOfSections() -> Int
    func numberOfItems(inSection section: Int) -> Int
    
    subscript(indexPath: NSIndexPath) -> Any { get }
    subscript(section: Int, index: Int) -> Any { get }
    
    func sectionItem(at section: Int) -> Any?
    
    weak var delegate: TTDataSourceDelegate? { get set }
    var feed: TTDataFeed? { get set }
    
    var dataSourceID: String? { get set } //usefull information
    
    func indexPath<S>(ofFirst filter: (item: S) -> Bool) -> NSIndexPath?
}

public extension TTDataSource {
    public func sectionItem(at section: Int) -> Any? {
        return nil
    }
}

public protocol TTDataSourceMutable {
    associatedtype Element
    
    func perfomBatchUpdates(@noescape updates: (() -> Void), animationCompletion:(()->Void)?);
    
    func append(_ newElement: Element)
    func append(contentsOf newElements: [Element])

    func insert(newElement: Element, at indexPath: NSIndexPath)
    func insert(contentsOf newElements: [Element], at indexPath: NSIndexPath)
    
    func moveElement(from fromIndexPath: NSIndexPath, to toIndexPath: NSIndexPath)
    func remove(at indexPaths: [NSIndexPath])
    func remove(at indexPath: NSIndexPath)
    func remove(@noescape filter: (item: Element) -> Bool)
    
    func replace(at indexPath: NSIndexPath, newElement: Element)
    
    subscript(indexPath: NSIndexPath) -> Element { get set }
    subscript(section: Int, index: Int) -> Element { get set }
}

extension TTDataSourceMutable where Element == Any {
    public func append<S>(contentsOf newElements: [S]) {
        let items: [Any] = newElements.map{$0 as Any}
        append(contentsOf: items)
    }
    
    public func insert<S>(contentsOf newElements: [S], at indexPath: NSIndexPath) {
        self.insert(contentsOf: newElements.map({$0 as Any}), at: indexPath)
    }
}


public protocol TTDataSourceDelegate: class {
    func dataSourceWillChangeContent(dataSource: TTDataSource)
    
    func dataSource(dataSource: TTDataSource, didUpdateItemsAt indexPaths: [NSIndexPath])
    func dataSource(dataSource: TTDataSource, didDeleteItemsAt indexPaths: [NSIndexPath])
    func dataSource(dataSource: TTDataSource, didInsertItemsAt indexPaths: [NSIndexPath])
    func dataSource(dataSource: TTDataSource, didMoveItemsFrom fromIndexPaths: [NSIndexPath], to toIndexPaths: [NSIndexPath])
    
    func dataSource(dataSource: TTDataSource, didInsertSections addedSections: NSIndexSet)
    func dataSource(dataSource: TTDataSource, didDeleteSections deletedSections: NSIndexSet)
    func dataSource(dataSource: TTDataSource, didUpdateSections updatedSections: NSIndexSet)
    
    func dataSourceDidChangeContent(dataSource: TTDataSource, animationCompletion:(() -> Void)?)
}

extension TTDataSourceDelegate {
    func dataSourceDidChangeContent(dataSource: TTDataSource) {
        dataSourceDidChangeContent(dataSource, animationCompletion: nil)
    }
}


extension TTDataSource {
    public var description: String {
        return String(self.dynamicType) + ": " + content.description
    }
}
