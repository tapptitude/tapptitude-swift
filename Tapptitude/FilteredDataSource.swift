//
//  FilteredDataSource.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 08/04/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

open class FilteredDataSource<T> : DataSource<T> {
    
    override public init(_ content: [T]) {
        super.init(content)
    }
    
    /// pass nil to reset filter
    open func filter(by filter: ((T) -> Bool)?) {
        self.filterBy = filter
        
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
    
    var filterBy: ((T) -> Bool)?
    
    open var isFiltered: Bool {
        return filterBy != nil
    }
    
    open var unfilteredContent: [T] {
        return originalContent ?? content.convertTo()
    }
    
    var originalContent: [T]?
//}
//
//extension FilteredDataSource {
    override open func dataFeed(_ dataFeed: TTDataFeed?, didReloadContent content: [Any]?) {
        var content = content
        
        if isFiltered {
            originalContent = content?.convertTo()
            content = originalContent?.filter(filterBy!).convertTo()
        }
        super.dataFeed(dataFeed, didReloadContent: content)
    }
    
    override open func dataFeed(_ dataFeed: TTDataFeed?, didLoadMoreContent content: [Any]?) {
        var content = content
        if isFiltered {
            let mappedContent: [T]? = content?.map({$0 as! T })
            originalContent?.append(contentsOf: mappedContent ?? [])
            content = content?.convertTo().filter(filterBy!).convertTo()
        }
        super.dataFeed(dataFeed, didLoadMoreContent: content)
    }
}
