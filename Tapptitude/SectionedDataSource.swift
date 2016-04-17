//
//  SectionedDataSource.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 11/04/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public class GroupedByDataSource<T, U: Hashable> : SectionedDataSource<T> {
    lazy private var _ungroupedContent : [T] = [T]()
    
    public var groupBy: (T -> U)?
    
    public init(content: [T] = [],  groupBy: (T -> U) ) {
        let groupedContent = content.groupBy(groupBy)
        
        super.init(groupedContent)
        _ungroupedContent = content
        self.groupBy = groupBy
    }
    
    override public func dataFeed(dataFeed: TTDataFeed?, didReloadContent content: [Any]?) {
        // pass delegate message
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, didReloadContent: content)
        }
        
        _unfilteredContent.removeAll()
        _ungroupedContent.removeAll()
        if let content = content {
            if let groupBy = groupBy {
                _ungroupedContent.appendContentsOf(content.map({$0 as! T}))
                _unfilteredContent = _ungroupedContent.groupBy(groupBy)
            } else {
                _unfilteredContent.appendContentsOf(content.map({$0 as! [T]}))
            }
        }
        
        filterContent()
        
        delegate?.dataSourceDidReloadContent(self)
    }
    
    override public func dataFeed(dataFeed: TTDataFeed?, didLoadMoreContent content: [Any]?) {
        // pass delegate message
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, didLoadMoreContent: content)
        }
        
        if let content = content {
            if let groupBy = groupBy {
                _ungroupedContent.appendContentsOf(content.map({$0 as! T}))
                _unfilteredContent = _ungroupedContent.groupBy(groupBy)
            } else {
                _unfilteredContent.appendContentsOf(content.map({$0 as! [T]}))
            }
        }
        
        filterContent()
        
        delegate?.dataSourceDidLoadMoreContent(self)
    }
}

public class SectionedDataSource <T>: TTDataSource, TTDataFeedDelegate {
    
    private var _unfilteredContent : [[T]] = [[T]]()
    lazy private var _content : [[T]] = [[T]]()
    
    public init(_ content : [[T]]) {
        _content = content
        _unfilteredContent = content
    }
    
    public init(_ content : NSArray) {
        _content = content.map({ let item = $0 as! Array<T>
            return item.map({ $0 as T })
        })
        _unfilteredContent = _content
    }
    
    public init() {
        _content = []
        _unfilteredContent = _content
    }
    
    var filter: (T -> Bool)?
    public func filterBy(filter: (T -> Bool)?) {
        self.filter = filter
        filterContent()
        self.delegate?.dataSourceDidReloadContent(self)
    }
    public var isFiltered: Bool {
        return filter != nil
    }
    
    func filterContent() {
        if let filterBy = filter {
            let toFilterContent = _unfilteredContent
            _content.removeAll()
            for item in toFilterContent {
                let subItems = item.filter(filterBy)
                if subItems.count > 0 {
                    _content.append(subItems)
                }
            }
        } else {
            _content = _unfilteredContent
        }
    }
    
    
    public weak var delegate : TTDataSourceDelegate?
    public var feed : TTDataFeed? {
        willSet {
            feed?.delegate = nil
        }
        didSet {
            feed?.delegate = self
        }
    }
    
    deinit {
        feed?.delegate = nil
    }
    
    public var content : [Any] {
        get {
            return _content.map({$0 as Any})
        }
    }
    
    public func hasContent() -> Bool {
        return _content.isEmpty == false
    }
    
    public func numberOfSections() -> Int {
        return _content.count
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        return _content[section].count
    }
    
    public func objectAtIndexPath(indexPath: NSIndexPath) -> Any {
        return _content[indexPath.section][indexPath.item]
    }
    
    public func indexPathForObject(object: Any) -> NSIndexPath? {
        //TODO: implement
        fatalError()
        
    // TODO: find a better way
    //        let index = _content.indexOf({ (searchedItem) -> Bool in
    //            return (searchedItem as Any) === object
    //        })
    //
    //        if index != nil {
    //            return NSIndexPath(forItem: index!, inSection: 0)
    //        } else {
    //            return nil
    //        }
    }
    
    public var dataSourceID : String?
    
    //}
    //
    //extension DataSource : TTDataFeedDelegate {
    
    public func dataFeed(dataFeed: TTDataFeed?, failedWithError error: NSError) {
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, failedWithError: error)
        }
    }
    
    public func dataFeed(dataFeed: TTDataFeed?, didReloadContent content: [Any]?) {
        // pass delegate message
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, didReloadContent: content)
        }
        
        _unfilteredContent.removeAll()
        if let content = content {
            _unfilteredContent.appendContentsOf(content.map({$0 as! [T]}))
        }
        
        filterContent()

        delegate?.dataSourceDidReloadContent(self)
    }
    
    public func dataFeed(dataFeed: TTDataFeed?, didLoadMoreContent content: [Any]?) {
        // pass delegate message
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, didLoadMoreContent: content)
        }
        
        if let content = content {
            _unfilteredContent.appendContentsOf(content.map({$0 as! [T]}))
        }
        
        filterContent()
        
        delegate?.dataSourceDidLoadMoreContent(self)
    }
    
    public func dataFeed(dataFeed: TTDataFeed?, isReloading: Bool) {
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, isReloading: isReloading)
        }
    }
    
    public func dataFeed(dataFeed: TTDataFeed?, isLoadingMore: Bool) {
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, isLoadingMore: isLoadingMore)
        }
    }
}

public extension SequenceType {
    public func groupBy<U : Hashable>(@noescape keyFunc: Generator.Element -> U) -> [[Generator.Element]] {
        
        var keys: [U] = []
        var dict: [U: [Generator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) {
                dict[key] = [el]
                keys.append(key)
            }
        }
        
        var groupedItems: [[Generator.Element]] = []
        for key in keys {
            groupedItems.append(dict[key]!)
        }
        
        return groupedItems
    }
}