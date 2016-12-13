//
//  DataSource.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

/// Single section dataSource used by TTCollectionFeedController
/// - use feed property to fetch data from API
open class DataSource<T> : TTDataSource, TTDataFeedDelegate, TTDataSourceMutable {
    public typealias Element = T
    
    lazy fileprivate var _content : [T] = [T]()
    
    public init(_ content : [T]) {
        _content = content
    }
    
    public init(_ content : NSArray) {
        _content = content.map({$0 as! T})
    }
    
    public init() {
        _content = []
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
        return 1
    }
    
    open func numberOfItems(inSection section: Int) -> Int {
        return _content.count
    }
    
    open func indexPath<S>(ofFirst filter: (_ item: S) -> Bool) -> IndexPath? {
        let index = _content.index { (item) -> Bool in
            if let item = item as? S {
                return filter(item)
            } else {
                return false
            }
        }
        
        return index != nil ? IndexPath(item: index!, section: 0) : nil
    }
    
    open subscript(indexPath: IndexPath) -> Any {
        get { return _content[indexPath.item] }
    }
    
    open subscript(indexPath: IndexPath) -> T {
        get { return _content[indexPath.item] }
        set { editContent { (_content, delegate) in
            _content[indexPath.item] = newValue
            }}
    }
    
    open subscript(section: Int, index: Int) -> Any {
        get { return _content[index] }
    }
    
    open subscript(section: Int, index: Int) -> T {
        get { return _content[index] }
        set { editContent { (_content, delegate) in
            _content[index] = newValue
            }}
    }
    
//    public subscript(index: Int) -> Any {
//        get { return _content[index] }
//    }
    
    open subscript(index: Int) -> T {
        get { return _content[index] }
        set { editContent { (_content, delegate) in
            _content[index] = newValue
            }}
    }
    
    open var dataSourceID : String?
    /// store/access any information here by using a unique key
    open var info: [String: Any] = [:]
    
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
        
        let wasEmpty = _content.isEmpty == true
        _content = content?.convertTo() ?? []
        let isEmpty = _content.isEmpty
        
        let ignore = wasEmpty && isEmpty
        if !ignore {
            delegate?.dataSourceWillChangeContent(self)
            delegate?.dataSource(self, didUpdateSections: IndexSet(integer: 0))
            delegate?.dataSourceDidChangeContent(self)
        }
    }
    
    open func dataFeed(_ dataFeed: TTDataFeed?, didLoadMoreContent content: [Any]?) {
        // pass delegate message
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, didLoadMoreContent: content)
        }
        
        var indexPaths = [IndexPath]();
        
        if let content = content {
            let startIndex = _content.count
            _content.append(contentsOf: content.map({$0 as! Element}))
            
            indexPaths = content.enumerated().map({ (index, _) -> IndexPath in
                return IndexPath(item: startIndex + index, section: 0)
            })
        }
        
        if !indexPaths.isEmpty {
            delegate?.dataSourceWillChangeContent(self)
            delegate?.dataSource(self, didInsertItemsAt: indexPaths)
            delegate?.dataSourceDidChangeContent(self)
        }
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
//}
//
//
//
//extension DataSource : TTDataSourceMutable {
    open func perfomBatchUpdates(_ updates: (() -> Void), animationCompletion:(()->Void)?) {
        assert(allowWillDidChangeContent, "perform batche updates called multiple times")
        allowWillDidChangeContent = false
        delegate?.dataSourceWillChangeContent(self)
        updates()
        delegate?.dataSourceDidChangeContent(self, animationCompletion: animationCompletion)
        allowWillDidChangeContent = true
    }
    
    fileprivate var allowWillDidChangeContent = true
    fileprivate func editContent(_ editBlock: ( _ content: inout [T], _ delegate: TTDataSourceDelegate?) -> Void) {
        if allowWillDidChangeContent {
            delegate?.dataSourceWillChangeContent(self)
        }
        editBlock(&_content, delegate);
        if allowWillDidChangeContent {
            delegate?.dataSourceDidChangeContent(self, animationCompletion: nil)
        }
    }
    
    open func append(_ newElement: T) {
        editContent { (_content, delegate) -> Void in
            _content.append(newElement)
            let maxCount = _content.count - 1
            let indexPath = IndexPath(item: maxCount > 0 ? maxCount : 0, section: 0)
            delegate?.dataSource(self, didInsertItemsAt: [indexPath])
        }
    }
    
    open func append(contentsOf newElements: [T]) {
        editContent { (_content, delegate) -> Void in
            let startIndex = _content.count
            let indexPaths = newElements.enumerated().map({ (index, _) -> IndexPath in
                return IndexPath(item: startIndex + index, section: 0)
            })
            
            _content.append(contentsOf: newElements)
            delegate?.dataSource(self, didInsertItemsAt: indexPaths)
        }
    }
    
    open func insert(_ newElement: T, at indexPath: IndexPath) {
        editContent { (_content, delegate) -> Void in
            _content.insert(newElement, at: indexPath.item)
            delegate?.dataSource(self, didInsertItemsAt: [indexPath])
        }
    }
    
    open func insert(contentsOf newElements: [T], at indexPath: IndexPath) {
        var insertedIndexPaths:[IndexPath] = []
        editContent { (_content, delegate) -> Void in
            var counter = 0
            for element in newElements {
                _content.insert(element, at: indexPath.item + counter)
                insertedIndexPaths.append(IndexPath(item: indexPath.item + counter, section: 0))
                counter += 1
            }
            delegate?.dataSource(self, didInsertItemsAt: insertedIndexPaths)
        }
    }

    
    open func moveElement(from fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        editContent { (_content, delegate) -> Void in
            let item = _content[fromIndexPath.item]
            _content.remove(at: fromIndexPath.item)
            
            var toIndex = toIndexPath.item
            if toIndexPath.item > fromIndexPath.item {
                toIndex -= 1
            }
            
            _content.insert(item, at: toIndex)
            
            delegate?.dataSource(self, didMoveItemsFrom: [fromIndexPath], to: [toIndexPath])
        }
    }
    
    open func remove(at indexPath: IndexPath) {
        editContent { (_content, delegate) -> Void in
            _content.remove(at: indexPath.item)
            delegate?.dataSource(self, didDeleteItemsAt: [indexPath])
        }
    }
    
    open func remove(at indexPaths: [IndexPath]) {
        if !indexPaths.isEmpty {
            var indexPathsToRemove:[Int] = indexPaths.map { return $0.item }
            editContent { (_content, delegate) -> Void in
                for j in 0..<indexPathsToRemove.count   {
                    _content.remove(at: indexPathsToRemove[j])
                    for i in 0..<indexPathsToRemove.count{
                        if indexPathsToRemove[i] > indexPathsToRemove[j] {
                            indexPathsToRemove[i] -= 1
                        }
                    }
                }
                delegate?.dataSource(self, didDeleteItemsAt: indexPaths)
            }
        }
    }
    
    open func remove(_ filter: (_ item: T) -> Bool) {
        editContent { (_content, delegate) -> Void in
            var indexPaths: [IndexPath] = []
            let content = _content
            var index = 0
            var collectionIndex = 0
            for item in content {
                if filter(item) {
                    _content.remove(at: index)
                    indexPaths.append(IndexPath(item: collectionIndex, section: 0))
                } else {
                    index += 1
                }
                collectionIndex += 1
            }
            delegate?.dataSource(self, didDeleteItemsAt: indexPaths)
        }
    }
    
    open func replace(at indexPath: IndexPath, newElement: T) {
        editContent { (_content, delegate) -> Void in
            _content[indexPath.item] = newElement
            delegate?.dataSource(self, didUpdateItemsAt: [indexPath])
        }
    }
}

public extension Sequence {
    public func convertTo<NewType>() -> [NewType] {
        return self.map {$0 as! NewType }
    }
}

public func += <T>(left: inout DataSource<T>, right: DataSource<T>) {
    left.append(contentsOf: right.content.convertTo())
}

public func += <T>(left: inout DataSource<T>, right: [T]) {
    left.append(contentsOf: right)
}


extension DataSource: Sequence {
    public typealias Iterator = AnyIterator<T>
    
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


extension DataSource : Collection {
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
    
    public var last: T? {
        return _content.last
    }
}


//extension DataSource: BidirectionalCollection {
//    
//}
