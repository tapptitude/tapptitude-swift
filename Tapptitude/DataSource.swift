//
//  DataSource.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public class DataSource<T> : TTDataSource, TTDataFeedDelegate, TTDataSourceMutable {
    public typealias Element = T
    
    lazy private var _content : [T] = [T]()
    
    public init(_ content : [T]) {
        _content = content
    }
    
    public init(_ content : NSArray) {
        _content = content.map({$0 as! T})
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
        return 1
    }
    
    public func numberOfItems(inSection section: Int) -> Int {
        return _content.count
    }
    
    public func indexPath<S>(ofFirst filter: (item: S) -> Bool) -> NSIndexPath? {
        let index = _content.indexOf { (item) -> Bool in
            if let item = item as? S {
                return filter(item: item)
            } else {
                return false
            }
        }
        
        return index != nil ? NSIndexPath(forItem: index!, inSection: 0) : nil
    }
    
    public subscript(indexPath: NSIndexPath) -> Any {
        get { return _content[indexPath.item] }
    }
    
    public subscript(indexPath: NSIndexPath) -> T {
        get { return _content[indexPath.item] }
        set { editContentWithBlock { (_content, delegate) in
            _content[indexPath.item] = newValue
            }}
    }
    
    public subscript(section: Int, index: Int) -> Any {
        get { return _content[index] }
    }
    
    public subscript(section: Int, index: Int) -> T {
        get { return _content[index] }
        set { editContentWithBlock { (_content, delegate) in
            _content[index] = newValue
            }}
    }
    
//    public subscript(index: Int) -> Any {
//        get { return _content[index] }
//    }
    
    public subscript(index: Int) -> T {
        get { return _content[index] }
        set { editContentWithBlock { (_content, delegate) in
            _content[index] = newValue
            }}
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
        
        let wasEmpty = content?.isEmpty == true
        _content = content?.convertTo() ?? []
        let isEmpty = _content.isEmpty
        
        let ignore = wasEmpty && isEmpty
        if !ignore {
            delegate?.dataSourceWillChangeContent(self)
            delegate?.dataSource(self, didUpdateSections: NSIndexSet(index: 0))
            delegate?.dataSourceDidChangeContent(self)
        }
    }
    
    public func dataFeed(dataFeed: TTDataFeed?, didLoadMoreContent content: [Any]?) {
        // pass delegate message
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, didLoadMoreContent: content)
        }
        
        var indexPaths = [NSIndexPath]();
        
        if let content = content {
            _content.appendContentsOf(content)
            
            indexPaths = content.enumerate().map({ (index, _) -> NSIndexPath in
                return NSIndexPath(forItem: index, inSection: 0)
            })
        }
        
        if !indexPaths.isEmpty {
            delegate?.dataSourceWillChangeContent(self)
            delegate?.dataSource(self, didInsertItemsAt: indexPaths)
            delegate?.dataSourceDidChangeContent(self)
        }
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
//}
//
//
//
//extension DataSource : TTDataSourceMutable {
    
    private func editContentWithBlock(editBlock: ( inout content: [T], delegate: TTDataSourceDelegate?) -> Void) {
        delegate?.dataSourceWillChangeContent(self)
        editBlock(content: &_content, delegate: delegate);
        delegate?.dataSourceDidChangeContent(self)
    }
    
    public func append(_ newElement: T) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content.append(newElement)
            let indexPath = NSIndexPath(forItem: max(0, _content.count - 1), inSection: 0)
            delegate?.dataSource(self, didInsertItemsAt: [indexPath])
        }
    }
    
    public func append(contentsOf newElements: [T]) {
        editContentWithBlock { (_content, delegate) -> Void in
            let startIndex = _content.count
            let indexPaths = newElements.enumerate().map({ (index, _) -> NSIndexPath in
                return NSIndexPath(forItem: startIndex + index, inSection: 0)
            })
            
            _content.appendContentsOf(newElements)
            delegate?.dataSource(self, didInsertItemsAt: indexPaths)
        }
    }
    
    public func insert(newElement: T, at indexPath: NSIndexPath) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content.insert(newElement, atIndex: indexPath.item)
            delegate?.dataSource(self, didInsertItemsAt: [indexPath])
        }
    }
    
    public func insert(contentsOf newElements: [T], at indexPath: NSIndexPath) {
        var insertedIndexPaths:[NSIndexPath] = []
        editContentWithBlock { (_content, delegate) -> Void in
            var counter = 0
            for element in newElements {
                _content.insert(element, atIndex: indexPath.item + counter)
                insertedIndexPaths.append(NSIndexPath(forItem: indexPath.item + counter, inSection: 0))
                counter += 1
            }
            delegate?.dataSource(self, didInsertItemsAt: insertedIndexPaths)
        }
    }

    
    public func moveElement(from fromIndexPath: NSIndexPath, to toIndexPath: NSIndexPath) {
        editContentWithBlock { (_content, delegate) -> Void in
            let item = _content[fromIndexPath.item]
            _content.removeAtIndex(fromIndexPath.item)
            
            var toIndex = toIndexPath.item
            if toIndexPath.item > fromIndexPath.item {
                toIndex -= 1
            }
            
            _content.insert(item, atIndex: toIndex)
            
            delegate?.dataSource(self, didMoveItemsFrom: [fromIndexPath], to: [toIndexPath])
        }
    }
    
    public func remove(at indexPath: NSIndexPath) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content.removeAtIndex(indexPath.item)
            delegate?.dataSource(self, didDeleteItemsAt: [indexPath])
        }
    }
    
    public func remove(at indexPaths: [NSIndexPath]) {
        if !indexPaths.isEmpty
        {
            var indexPathsToRemove:[Int] = indexPaths.map { return $0.item }
            editContentWithBlock { (_content, delegate) -> Void in
                for j in 0..<indexPathsToRemove.count   {
                    _content.removeAtIndex(indexPathsToRemove[j])
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
    
    public func remove(filter: (item: T) -> Bool) {
        editContentWithBlock { (_content, delegate) -> Void in
            var indexPaths: [NSIndexPath] = []
            let content = _content
            var index = 0
            var collectionIndex = 0
            for item in content {
                if filter(item: item) {
                    _content.removeAtIndex(index)
                    indexPaths.append(NSIndexPath(forItem: collectionIndex, inSection: 0))
                } else {
                    index += 1
                }
                collectionIndex += 1
            }
            delegate?.dataSource(self, didDeleteItemsAt: indexPaths)
        }
    }
    
    public func replace(at indexPath: NSIndexPath, newElement: T) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content[indexPath.item] = newElement
            delegate?.dataSource(self, didUpdateItemsAt: [indexPath])
        }
    }
}

public extension SequenceType {
    public func convertTo<NewType>() -> [NewType] {
        return self.map {$0 as! NewType }
    }
}

public func += <T>(inout left: DataSource<T>, right: DataSource<T>) {
    left.append(contentsOf: right.content.convertTo())
}

public func += <T>(inout left: DataSource<T>, right: [T]) {
    left.append(contentsOf: right)
}


extension DataSource: SequenceType {
    public typealias Generator = AnyGenerator<T>
    
    public func generate() -> Generator {
        var index = 0
        return AnyGenerator {
            if index < self._content.count {
                defer {index += 1}
                return self._content[index]
            }
            return nil
        }
    }
}


extension DataSource : CollectionType {
    public typealias Index = Int
    
    public var startIndex: Int {
        return _content.startIndex
    }
    
    public var endIndex: Int {
        return _content.endIndex
    }
}