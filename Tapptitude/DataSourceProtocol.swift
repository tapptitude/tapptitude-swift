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

public protocol TTDataSource : TTDataFeedDelegate {
    
    var content : [Any] { get }
    func hasContent() -> Bool
    func numberOfSections() -> Int
    func numberOfRowsInSection(section: Int) -> Int
    func objectAtIndexPath(indexPath: NSIndexPath) -> Any
    
    func indexPathForObject(object: Any) -> NSIndexPath?
    
    weak var delegate: TTDataSourceDelegate? { get set }
    var feed: TTDataFeed? { get set }
    
    var dataSourceID: String? { get set } //usefull information
}



public protocol TTDataSourceMutable {
    func addContent(content: Any)
    func addContentFromArray(array: [Any])
    func insertContent(content: Any, atIndexPath indexPath: NSIndexPath)
    
    func moveContentFromIndexPath(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    func removeContentFromIndexPath(indexPath: NSIndexPath)
    func removeContent(content: Any)
    
    func replaceContentAtIndexPath(indexPath: NSIndexPath, content: Any)
}