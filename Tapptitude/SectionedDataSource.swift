//
//  SectionedDataSource.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 11/04/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

open class SectionedDataSource <T>: TTDataSource, TTDataFeedDelegate {
    
    fileprivate var _unfilteredContent : [[T]] = [[T]]()
    lazy fileprivate var _content : [[T]] = [[T]]()
    
    public init(_ content : [[T]] = []) {
        _content = content
        _unfilteredContent = content
    }
    
    public init(_ content : NSArray) {
        _content = content.map({ let item = $0 as! Array<T>
            return item.map({ $0 as T })
        })
        _unfilteredContent = _content
    }
    
    var filter: ((T) -> Bool)?
    open func filter(_ filter: ((T) -> Bool)?) {
        self.filter = filter
        filterContent()
        self.delegate?.dataSourceDidChangeContent(self)
    }
    open var isFiltered: Bool {
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
    
    
    open weak var delegate : TTDataSourceDelegate?
    open var feed : TTDataFeed? {
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
    
    open var content : [Any] {
        get {
            return _content.map({$0 as Any})
        }
    }
    
    open func hasContent() -> Bool {
        return _content.isEmpty == false
    }
    
    open func numberOfSections() -> Int {
        return _content.count
    }
    
    open func numberOfItems(inSection section: Int) -> Int {
        return _content[section].count
    }
    
    open subscript(indexPath: IndexPath) -> T {
        get { return _content[indexPath.section][indexPath.item] }
        set {
            delegate?.dataSourceWillChangeContent(self)
            _content[indexPath.section][indexPath.item] = newValue
            delegate?.dataSource(self, didUpdateItemsAt: [indexPath])
            delegate?.dataSourceDidChangeContent(self) // TODO: support incremental changes
        }
    }
    
    open subscript(indexPath: IndexPath) -> Any {
        get { return _content[indexPath.section][indexPath.item] }
        set {
            delegate?.dataSourceWillChangeContent(self)
            _content[indexPath.section][indexPath.item] = (newValue as! T)
            delegate?.dataSource(self, didUpdateItemsAt: [indexPath])
            delegate?.dataSourceDidChangeContent(self) // TODO: support incremental changes
        }
    }
    
    open subscript(section: Int, index: Int) -> T {
        get { return _content[section][index] }
        set {
            delegate?.dataSourceWillChangeContent(self)
            _content[section][index] = newValue
            let indexPath = IndexPath(item: index, section: section)
            delegate?.dataSource(self, didUpdateItemsAt: [indexPath])
            delegate?.dataSourceDidChangeContent(self)
        }
    }
    
    open subscript(section: Int, index: Int) -> Any {
        get { return _content[section][index] }
        set {
            delegate?.dataSourceWillChangeContent(self)
            _content[section][index] = (newValue as! T)
            let indexPath = IndexPath(item: index, section: section)
            delegate?.dataSource(self, didUpdateItemsAt: [indexPath])
            delegate?.dataSourceDidChangeContent(self)
        }
    }
    
    open func remove(at indexPath: IndexPath) {
        delegate?.dataSourceWillChangeContent(self)
        _content[indexPath.section].remove(at: indexPath.item)
        delegate?.dataSource(self, didDeleteItemsAt: [indexPath])
        delegate?.dataSourceDidChangeContent(self)
    }
    
    open var dataSourceID : String?
    
    open func indexPath<S>(ofFirst filter: (_ item: S) -> Bool) -> IndexPath? {
        var i = 0
        for subArray in _content {
            let index = subArray.index(where: { (searchedItem) -> Bool in
                if let item = searchedItem as? S {
                    return filter(item)
                } else {
                    return false
                }
            })
            
            if let index = index {
                return IndexPath(item: index, section: 0)
            }
            
            i += 1
        }
        
        return nil
    }
    
//    public func indexPath<T: Equatable>(of element: T) -> IndexPath? {
//        var i = 0
//        for subArray in _content {
//            let index = subArray.indexOf({ (searchedItem) -> Bool in
//                if let item = searchedItem as? T {
//                    return item == element
//                }
//                return false
//            })
//            
//            if let index = index {
//                return IndexPath(item: index, section: 0)
//            }
//            
//            i += 1
//        }
//        
//        return nil
//    }
//
//    public func indexPath<T: AnyObject>(of element: T) -> IndexPath? {
//        var i = 0
//        for subArray in _content {
//            let index = subArray.indexOf({ (searchedItem) -> Bool in
//                if let item = searchedItem as? T {
//                    return item === element
//                }
//                return false
//            })
//            
//            if let index = index {
//                return IndexPath(item: index, section: 0)
//            }
//            
//            i += 1
//        }
//        
//        return nil
//    }
    
    //}
    //
    //extension DataSource : TTDataFeedDelegate {
    
    open func dataFeed(_ dataFeed: TTDataFeed?, failedWithError error: Error) {
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, failedWithError: error)
        }
    }
    
    open func dataFeed(_ dataFeed: TTDataFeed?, didReloadContent content: [Any]?) {
        // pass delegate message
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, didReloadContent: content)
        }
        
        _unfilteredContent.removeAll()
        if let content = content {
            _unfilteredContent.append(contentsOf: content.map({$0 as! [T]}))
        }
        
        filterContent()

        delegate?.dataSourceDidChangeContent(self)
    }
    
    open func dataFeed(_ dataFeed: TTDataFeed?, didLoadMoreContent content: [Any]?) {
        // pass delegate message
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, didLoadMoreContent: content)
        }
        
        if let content = content {
            _unfilteredContent.append(contentsOf: content.map({$0 as! [T]}))
        }
        
        filterContent()
        
        delegate?.dataSourceDidChangeContent(self)
    }
    
    open func dataFeed(_ dataFeed: TTDataFeed?, isReloading: Bool) {
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, isReloading: isReloading)
        }
    }
    
    open func dataFeed(_ dataFeed: TTDataFeed?, isLoadingMore: Bool) {
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, isLoadingMore: isLoadingMore)
        }
    }
}


open class GroupedByDataSource<T, U: Hashable> : SectionedDataSource<T> {
    lazy fileprivate var _ungroupedContent : [T] = [T]()
    
    open var groupBy: ((T) -> U)?
    
    public init(content: [T] = [],  groupBy: @escaping ((T) -> U) ) {
        let groupedContent = content.groupBy(groupBy)
        
        super.init(groupedContent)
        _ungroupedContent = content
        self.groupBy = groupBy
    }
    
    override open func dataFeed(_ dataFeed: TTDataFeed?, didReloadContent content: [Any]?) {
        // pass delegate message
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, didReloadContent: content)
        }
        
        _unfilteredContent.removeAll()
        _ungroupedContent.removeAll()
        if let content = content {
            if let groupBy = groupBy {
                _ungroupedContent.append(contentsOf: content.map({$0 as! T}))
                _unfilteredContent = _ungroupedContent.groupBy(groupBy)
            } else {
                _unfilteredContent.append(contentsOf: content.map({$0 as! [T]}))
            }
        }
        
        filterContent()
        
        delegate?.dataSourceDidChangeContent(self)
    }
    
    override open func dataFeed(_ dataFeed: TTDataFeed?, didLoadMoreContent content: [Any]?) {
        // pass delegate message
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, didLoadMoreContent: content)
        }
        
        if let content = content {
            if let groupBy = groupBy {
                _ungroupedContent.append(contentsOf: content.map({$0 as! T}))
                _unfilteredContent = _ungroupedContent.groupBy(groupBy)
            } else {
                _unfilteredContent.append(contentsOf: content.map({$0 as! [T]}))
            }
        }
        
        filterContent()
        
        delegate?.dataSourceDidChangeContent(self)
    }
}

public extension Sequence {
    public func groupBy<U : Hashable>(_ keyFunc: (Iterator.Element) -> U) -> [[Iterator.Element]] {
        
        var keys: [U] = []
        var dict: [U: [Iterator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) {
                dict[key] = [el]
                keys.append(key)
            }
        }
        
        var groupedItems: [[Iterator.Element]] = []
        for key in keys {
            groupedItems.append(dict[key]!)
        }
        
        return groupedItems
    }
}
