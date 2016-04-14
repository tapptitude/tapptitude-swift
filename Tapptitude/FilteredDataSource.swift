//
//  FilteredDataSource.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 08/04/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public class FilteredDataSource: DataSource {
    // setting the predicate will cause the datasource to reload
    public var filter: ((item: Any) -> Bool)? { //pass nil to reset filter
        didSet {
//            if (! predicate) {
//                if (self.originalContent) {
//                    [super dataFeed:nil didReloadContent:self.originalContent];
//                    self.originalContent = nil;
//                }
//            } else {
//                self.originalContent = self.originalContent ? self.originalContent : [self.content mutableCopy];
//                
//                NSArray *filteredArray = [self.originalContent filteredArrayUsingPredicate:predicate];
//                [super dataFeed:nil didReloadContent:filteredArray];
//            }
        }
    }
    
    public var isFiltered: Bool {
        return originalContent != nil
    }
    
    public var unfilteredContent: [Any] {
        return originalContent ?? content
    }
    
    var originalContent: [Any]?
//}
//
//extension FilteredDataSource {
    override public func dataFeed(dataFeed: TTDataFeed?, didReloadContent content: [Any]?) {
        var content = content
        if isFiltered {
            originalContent = content
            for item in content! {
                if filter?(item: item) == true {
                    
                }
            }
//            content = [content filteredArrayUsingPredicate:self.predicate];
        }
        super.dataFeed(dataFeed, didReloadContent: content)
    }
    
    override public func dataFeed(dataFeed: TTDataFeed?, didLoadMoreContent content: [Any]?) {
        var content = content
        if isFiltered {
            originalContent?.appendContentsOf(content ?? [])
//            content = [content filteredArrayUsingPredicate:self.predicate];
        }
        super.dataFeed(dataFeed, didLoadMoreContent: content)
    }
}