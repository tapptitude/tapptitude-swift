//
//  FilteredDataSource.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 08/04/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public class FilteredDataSource<T> : DataSource {

    public init(_ content : [T]) {
        super.init(content.convertTo())
    }
    
    public var filterBy: (T -> Bool)? { //pass nil to reset filter
        didSet {
            if filterBy == nil {
                if originalContent != nil {
                    super.dataFeed(nil, didReloadContent: originalContent!.convertTo())
                    originalContent = nil
                }
            } else {
                originalContent = originalContent ?? content.convertTo()
                
                let filteredContent: [Any]? = originalContent!.filter(filterBy!).convertTo()
                super.dataFeed(nil, didReloadContent: filteredContent)
            }
        }
    }
    
    public var isFiltered: Bool {
        return filterBy != nil
    }
    
    public var unfilteredContent: [T] {
        return originalContent ?? content.convertTo()
    }
    
    var originalContent: [T]?
//}
//
//extension FilteredDataSource {
    override public func dataFeed(dataFeed: TTDataFeed?, didReloadContent content: [Any]?) {
        var content = content
        
        if isFiltered {
            originalContent = content?.convertTo()
            content = originalContent?.filter(filterBy!).convertTo()
        }
        super.dataFeed(dataFeed, didReloadContent: content)
    }
    
    override public func dataFeed(dataFeed: TTDataFeed?, didLoadMoreContent content: [Any]?) {
        var content = content
        if isFiltered {
            originalContent?.appendContentsOf(content ?? [])
            content = content?.convertTo().filter(filterBy!).convertTo()
        }
        super.dataFeed(dataFeed, didLoadMoreContent: content)
    }
}