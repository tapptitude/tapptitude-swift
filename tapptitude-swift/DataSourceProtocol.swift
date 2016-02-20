//
//  DataSourceProtocol.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public protocol TTDataSourceDelegate {
    func dataSourceDidReloadContent(dataSource: TTDataSource)
    func dataSourceDidLoadMoreContent(dataSource: TTDataSource)
}

public protocol TTDataSource : TTDataFeedDelegate {
    
    var content : [AnyObject] { get }
    func hasContent() -> Bool
    func numberOfSections() -> Int
    func numberOfRowsInSection(section: Int) -> Int
    func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject
    
    func indexPathForObject(object: AnyObject) -> NSIndexPath?
    
    var delegate: TTDataSourceDelegate? { get set }
    var feed: DataFeed? { get set }
    
    var dataSourceID: String? { get set } //usefull information
}



public protocol TTDataSourceMutable {
    func addContent(content: AnyObject)
    func addContentFromArray(array: [AnyObject])
    func insertContent(content: AnyObject, atIndexPath indexPath: NSIndexPath)
    
    func moveContentFromIndexPath(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    func removeContentFromIndexPath(indexPath: NSIndexPath)
    func removeContent(content: AnyObject)
}