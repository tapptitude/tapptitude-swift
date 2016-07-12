//
//  DataSource.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation


public class DataSource : TTDataSource, TTDataFeedDelegate, TTDataSourceMutable {
    lazy private var _content : [Any] = [Any]()
    
    public init<T>(_ content : [T]) {
        _content = content.map({$0 as Any})
    }
    
    public init(_ content : NSArray) {
        _content = content.map({$0 as Any})
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
            return _content
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
    
    public func indexPath(of element: Any) -> NSIndexPath? {
        return nil
    }
    
    public func indexPath<T: Equatable>(of element: T) -> NSIndexPath? {
        
        let index = _content.indexOf({ (searchedItem) -> Bool in
            if let item = searchedItem as? T {
                return item == element
            }
            return false
        })
        
        return index != nil ? NSIndexPath(forItem: index!, inSection: 0) : nil
    }
    
    public func indexPath<T: AnyObject>(of element: T) -> NSIndexPath? {
        let index = _content.indexOf({ (searchedItem) -> Bool in
            if let item = searchedItem as? T {
                return item === element
            }
            return false
        })
        
        return index != nil ? NSIndexPath(forItem: index!, inSection: 0) : nil
    }
    
    public subscript(indexPath: NSIndexPath) -> Any {
        get { return _content[indexPath.item] }
        set { editContentWithBlock { (_content, delegate) in
            _content[indexPath.item] = newValue
            }}
    }
    
    public subscript(section: Int, index: Int) -> Any {
        get { return _content[index] }
        set { editContentWithBlock { (_content, delegate) in
            _content[index] = newValue
            }}
    }
    
    public subscript(index: Int) -> Any {
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
        _content = content ?? []
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
    
    private func editContentWithBlock(editBlock: ( inout content: [Any], delegate: TTDataSourceDelegate?) -> Void) {
        delegate?.dataSourceWillChangeContent(self)
        editBlock(content: &_content, delegate: delegate);
        delegate?.dataSourceDidChangeContent(self)
    }
    
    public func append<S>(_ newElement: S) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content.append(newElement)
            let indexPath = NSIndexPath(forItem: _content.count, inSection: 0)
            delegate?.dataSource(self, didInsertItemsAt: [indexPath])
        }
    }
    
    public func append<S>(contentsOf newElements: [S]) {
        editContentWithBlock { (_content, delegate) -> Void in
            let startIndex = _content.count
            let indexPaths = newElements.enumerate().map({ (index, _) -> NSIndexPath in
                return NSIndexPath(forItem: startIndex + index, inSection: 0)
            })
            
            _content.appendContentsOf(newElements.map{$0 as Any})
            delegate?.dataSource(self, didInsertItemsAt: indexPaths)
        }
    }
    
    public func insert<S>(newElement: S, at indexPath: NSIndexPath) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content.insert(newElement, atIndex: indexPath.item)
            delegate?.dataSource(self, didInsertItemsAt: [indexPath])
        }
    }
    
    public func insert<S>(contentsOf newElements: [S], at indexPath: NSIndexPath) {
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
    
    public func removeWith(filter: (item: Any) -> Bool) {
        editContentWithBlock { (_content, delegate) -> Void in
            var indexPaths: [NSIndexPath] = []
            for (index, item) in _content.enumerate() {
                if filter(item: item) {
                    _content.removeAtIndex(index)
                    indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                }
            }
            delegate?.dataSource(self, didDeleteItemsAt: indexPaths)
        }
    }
    
    public func remove<S>(_ element: S) {
        if let indexPath = self.indexPath(of: element) {
            self.remove(at: indexPath)
        } else {
            print("Element not found \(element) in dataSource")
        }
    }
    
    public func replace<S>(at indexPath: NSIndexPath, newElement: S) {
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

public func += (inout left: DataSource, right: DataSource) {
    left.append(right.content)
}

public func += <T>(inout left: DataSource, right: [T]) {
    left.append(contentsOf: right)
}