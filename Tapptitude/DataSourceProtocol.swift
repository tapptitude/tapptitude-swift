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
    
    func indexPath(of element: Any) -> NSIndexPath?
    
    weak var delegate: TTDataSourceDelegate? { get set }
    var feed: TTDataFeed? { get set }
    
    var dataSourceID: String? { get set } //usefull information
}

public extension TTDataSource {
    public func sectionItem(at section: Int) -> Any? {
        return nil
    }
}

public protocol TTDataSourceMutable {
    func append<S>(_ newElement: S)
    func append<S>(contentsOf newElements: [S])
    
    func insert<S>(newElement: S, at indexPath: NSIndexPath)
    func insert<S>(contentsOf newElements: [S], at indexPath: NSIndexPath)
    
    func moveElement(from fromIndexPath: NSIndexPath, to toIndexPath: NSIndexPath)
    func remove(at indexPaths: [NSIndexPath])
    func remove(at indexPath: NSIndexPath)
    func remove<S>(_ item: S)
    func removeWith(filter: (item: Any) -> Bool)
    
    func replace<S>(at indexPath: NSIndexPath, newElement: S)
    
    subscript(indexPath: NSIndexPath) -> Any { get set }
    subscript(section: Int, index: Int) -> Any { get set }
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
    
    func dataSourceDidChangeContent(dataSource: TTDataSource)
}


extension TTDataSource {
    public var description: String {
        return String(self.dynamicType) + ": " + content.description
    }
}