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
    
    public convenience required init(arrayLiteral: T...) {
        self.init(arrayLiteral.map({ $0 }))
    }
    
    /// pass nil to reset filter
    open func filter(by filter: ((T) -> Bool)?) {
        self.filterBy = filter
        
        if filterBy == nil {
            if originalContent != nil {
                let filteredContent: [Any]? = originalContent!.convertTo()
                let result = Result.success(filteredContent ?? [])
                super.dataFeed(nil, didLoadResult: result, forState: .reloading)
                originalContent = nil
            }
        } else {
            originalContent = originalContent ?? content
            
            let filteredContent: [Any]? = originalContent!.filter(filterBy!).convertTo()
            let result = Result.success(filteredContent ?? [])
            super.dataFeed(nil, didLoadResult: result, forState: .reloading)
        }
    }
    
    var filterBy: ((T) -> Bool)?
    
    open var isFiltered: Bool {
        return filterBy != nil
    }
    
    open var unfilteredContent: [T] {
        return originalContent ?? content
    }
    
    var originalContent: [T]?
//}
//
//extension FilteredDataSource {
    override open func dataFeed(_ dataFeed: TTDataFeed?, didLoadResult result: Result<[Any]>, forState: FeedState.Load) {
        var result = result
        if let filterBy = filterBy {
            let resultType = result.map(as: T.self)
            
            switch (forState) {
            case .reloading:
                originalContent = resultType.value ?? []
            case .loadingMore:
                originalContent?.append(contentsOf: resultType.value ?? [])
            }
            
            result = resultType.map{ $0.filter(filterBy) }.map(as: Any.self)
        }
        
        super.dataFeed(dataFeed, didLoadResult: result, forState: forState)
    }
}
