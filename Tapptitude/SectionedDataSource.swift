//
//  SectionedDataSource.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 11/04/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public class SectionedDataSource : TTDataSource, TTDataFeedDelegate {
    lazy private var _content : [[Any]] = [[Any]]()
    
    public init(_ content : [[Any]]) {
        _content = content.map({$0 as [Any]})
    }
    
    public init(_ content : [[AnyObject]]) {
        _content = content.map({$0 as [Any]})
    }
    
    public init(_ content : NSArray) {
        _content = content.map({ let item = $0 as! Array<AnyObject>
            return item.map({ $0 as Any })
        })
    }
    
    public init() {
        _content = []
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
        
        _content.removeAll()
        if let content = content {
            _content = content.map({ let item = $0 as! NSArray
                return item.map({ $0 as Any })
            })
        }
        
        delegate?.dataSourceDidReloadContent(self)
    }
    
    public func dataFeed(dataFeed: TTDataFeed?, didLoadMoreContent content: [Any]?) {
        // pass delegate message
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, didLoadMoreContent: content)
        }
        
        if let content = content {
            _content.append(content)
        }
        
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

