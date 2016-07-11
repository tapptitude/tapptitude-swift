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
    func numberOfItemsInSection(section: Int) -> Int
    
    subscript(indexPath: NSIndexPath) -> Any { get }
    subscript(section: Int, index: Int) -> Any { get }
    
    func sectionItem(at section: Int) -> Any?
    
    func indexPathOf(element: Any) -> NSIndexPath?
    
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
    func append<S>(newElement: S)
    func appendContentsOf<S>(newElements: [S])
    
    func insert<S>(newElement: S, atIndexPath indexPath: NSIndexPath)
    func insert<S>(newElements: [S], atIndexPath indexPath: NSIndexPath)
    
    func moveElementFromIndexPath(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    func removeAt(indexPaths: [NSIndexPath])
    func removeAtIndexPath(indexPath: NSIndexPath)
    func remove<S>(item: S)
    func removeWith(filter: (item: Any) -> Bool)
    
    func replaceAtIndexPath<S>(indexPath: NSIndexPath, newElement: S)
    
    subscript(indexPath: NSIndexPath) -> Any { get set }
    subscript(section: Int, index: Int) -> Any { get set }
}


public protocol TTDataSourceDelegate: class {
    func dataSourceWillChangeContent(dataSource: TTDataSource)
    
    func dataSource(dataSource: TTDataSource, didUpdateItemsAtIndexPaths indexPaths: [NSIndexPath])
    func dataSource(dataSource: TTDataSource, didDeleteItemsAtIndexPaths indexPaths: [NSIndexPath])
    func dataSource(dataSource: TTDataSource, didInsertItemsAtIndexPaths indexPaths: [NSIndexPath])
    func dataSource(dataSource: TTDataSource, didMoveItemsAtIndexPaths fromIndexPaths: [NSIndexPath], toIndexPaths: [NSIndexPath])
    
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