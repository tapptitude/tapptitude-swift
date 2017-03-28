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
        _content = content.map({
            let item = $0 as! Array<T>
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
    
    open var isEmpty: Bool {
        return _content.isEmpty
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
    
    open subscript(section: Int) -> [T] {
        get { return _content[section] }
        set {
            delegate?.dataSourceWillChangeContent(self)
            _content[section] = newValue
            delegate?.dataSource(self, didUpdateSections: IndexSet(integer: section))
            delegate?.dataSourceDidChangeContent(self) // TODO: support incremental changes
        }
    }
    
    open var sectionHeaders: [Any]? {
        didSet {
            if let sectionHeaders = sectionHeaders {
                assert(sectionHeaders.count == _content.count, "We should have same count for number of sections")
            }
        }
    }
    open func sectionHeaderItem(at section: Int) -> Any? {
        return sectionHeaders?[section] ?? _content[section]
    }
    
    open var dataSourceID : String?
    
    open func indexPath<S>(ofFirst filter: (_ item: S) -> Bool) -> IndexPath? {
        for (section, subArray) in _content.enumerated() {
            let index = subArray.index(where: { (searchedItem) -> Bool in
                if let item = searchedItem as? S {
                    return filter(item)
                } else {
                    return false
                }
            })
            
            if let index = index {
                return IndexPath(item: index, section: section)
            }
        }
        
        return nil
    }
    
    private func editContentWithBlock(editBlock: ( _ content: inout [[T]], _ delegate: TTDataSourceDelegate?) -> Void) {
        delegate?.dataSourceWillChangeContent(self)
        editBlock(&_content, delegate);
        delegate?.dataSourceDidChangeContent(self)
    }
    
    open func append(sections newSections: [[T]]) {
        insert(sections: newSections, at: _content.count)
    }
    
    open func insert(_ element: T, at indexPath: IndexPath) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content[indexPath.section].insert(element, at: indexPath.item)
            delegate?.dataSource(self, didInsertItemsAt: [indexPath])
        }
    }
    
    open func insert(contentsOf newElements: [T], at indexPath: IndexPath) {
        if newElements.isEmpty {
            return
        }
        
        editContentWithBlock { (_content, delegate) -> Void in
            let startIndex = indexPath.item
            let endIndex = startIndex + newElements.count - 1
            _content[indexPath.section].insert(contentsOf: newElements, at: startIndex)
            let insertedIndexPaths = (startIndex...endIndex).map({ IndexPath(item: $0, section: indexPath.section) })
            delegate?.dataSource(self, didInsertItemsAt: insertedIndexPaths)
        }
    }
    
    open func insert(sections newSections: [[T]], at section: Int) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content.insert(contentsOf: newSections, at: section)
            let sections = IndexSet(section...(section+newSections.count))
            delegate?.dataSource(self, didInsertSections: sections)
        }
    }
    
    open func moveElement(from fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        editContentWithBlock { (_content, delegate) -> Void in
            let item = _content[fromIndexPath.section][fromIndexPath.item]
            _content[fromIndexPath.section].remove(at: fromIndexPath.item)
            
            var toIndex = toIndexPath.item
            let sameSection = fromIndexPath.section == toIndexPath.section
            if sameSection && toIndexPath.item > fromIndexPath.item {
                toIndex -= 1
            }
            
            _content[toIndexPath.section].insert(item, at: toIndex)
            
            delegate?.dataSource(self, didMoveItemsFrom: [fromIndexPath], to: [toIndexPath])
        }
    }
    
    open func remove(at indexPath: IndexPath) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content[indexPath.section].remove(at: indexPath.item)
            delegate?.dataSource(self, didDeleteItemsAt: [indexPath])
        }
    }
    
    open func remove(at indexPaths: [IndexPath]) {
        if indexPaths.isEmpty {
            return
        }
        
        let sortedIndexPaths = indexPaths.sorted()
        editContentWithBlock { (_content, delegate) -> Void in
            sortedIndexPaths.reversed().forEach{ _content[$0.section].remove(at: $0.item) }
            delegate?.dataSource(self, didDeleteItemsAt: indexPaths)
        }
    }
    
    open func remove(_ filter: (_ item: T) -> Bool) {
        editContentWithBlock { (_content, delegate) -> Void in
            var indexPaths: [IndexPath] = []
            let sections = _content
            for (section, content) in sections.enumerated() {
                var removeIndex = 0
                for (index, item) in content.enumerated() {
                    if filter(item) {
                        _content[section].remove(at: removeIndex)
                        indexPaths.append(IndexPath(item: index, section: section))
                    } else {
                        removeIndex += 1
                    }
                }
            }
            delegate?.dataSource(self, didDeleteItemsAt: indexPaths)
        }
    }
        
    //}
    //
    //extension DataSource : TTDataFeedDelegate {
    
    open func dataFeed(_ dataFeed: TTDataFeed?, didLoadResult result: Result<[Any]>, forState: FeedState.Load) {
        // pass delegate message
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, didLoadResult: result, forState: forState)
        }
        
        guard result.isSuccess else {
            return
        }
        
        switch forState {
        case .reloading:
            _unfilteredContent.removeAll()
            fallthrough
        case .loadingMore:
            delegate?.dataSourceWillChangeContent(self)
            if let content = result.value {
                _unfilteredContent.append(contentsOf: content.map({$0 as! [T]}))
            }
            
            filterContent()
            
            delegate?.dataSourceDidChangeContent(self)
        }
    }
    
    open func dataFeed(_ dataFeed: TTDataFeed?, fromState: FeedState, toState: FeedState) {
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, fromState: fromState, toState: toState)
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
    
    override open func dataFeed(_ dataFeed: TTDataFeed?, didLoadResult result: Result<[Any]>, forState: FeedState.Load) {
        // pass delegate message
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, didLoadResult: result, forState: forState)
        }
        
        guard result.isSuccess else {
            return
        }
        
        switch forState {
        case .reloading:
            _unfilteredContent.removeAll()
            _ungroupedContent.removeAll()
            fallthrough
        case .loadingMore:
            delegate?.dataSourceWillChangeContent(self)
            
            if let content = result.value {
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


extension SectionedDataSource: Sequence {
    public typealias Iterator = AnyIterator<[T]>
    
    public func makeIterator() -> Iterator {
        var index = 0
        return AnyIterator {
            if index < self._content.count {
                defer {index += 1}
                return self._content[index]
            }
            return nil
        }
    }
}


extension SectionedDataSource : Collection {
    public typealias Index = Int
    
    public var startIndex: Int {
        return _content.startIndex
    }
    
    public var endIndex: Int {
        return _content.endIndex
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
}

extension SectionedDataSource: BidirectionalCollection {
    public func index(before i: Int) -> Int {
        return i - 1
    }
}
