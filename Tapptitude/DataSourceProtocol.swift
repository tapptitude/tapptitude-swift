//
//  DataSourceProtocol.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public protocol TTDataSourceDelegate: class {
    func dataSourceDidReloadContent(dataSource: TTDataSource)
    func dataSourceDidLoadMoreContent(dataSource: TTDataSource)
}

public protocol TTDataSource : TTDataFeedDelegate, CustomStringConvertible {
    
    var content : [Any] { get }
    func hasContent() -> Bool
    func numberOfSections() -> Int
    func numberOfRowsInSection(section: Int) -> Int
    func elementAtIndexPath(indexPath: NSIndexPath) -> Any
    
    func indexPathForElement(element: Any) -> NSIndexPath?
    
    weak var delegate: TTDataSourceDelegate? { get set }
    var feed: TTDataFeed? { get set }
    
    var dataSourceID: String? { get set } //usefull information
}



public protocol TTDataSourceMutable {
    func append<S>(newElement: S)
    func appendContentsOf<S>(newElements: [S])
    
    func insert<S>(newElement: S, atIndexPath indexPath: NSIndexPath)
    
    func moveElementFromIndexPath(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    func removeAtIndexPath(indexPath: NSIndexPath)
    func remove<S>(item: S)
    
    func replaceAtIndexPath<S>(indexPath: NSIndexPath, newElement: S)
}


public protocol TTDataSourceIncrementalChangesDelegate {
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