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
    
    public func numberOfItemsInSection(section: Int) -> Int {
        return _content.count
    }
    
    public func indexPathOf(element: Any) -> NSIndexPath? {
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
            delegate?.dataSource(self, didInsertItemsAtIndexPaths: indexPaths)
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
    
    public func append<S>(newElement: S) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content.append(newElement)
            let indexPath = NSIndexPath(forItem: _content.count, inSection: 0)
            delegate?.dataSource(self, didInsertItemsAtIndexPaths: [indexPath])
        }
    }
    
    public func appendContentsOf<S>(newElements: [S]) {
        editContentWithBlock { (_content, delegate) -> Void in
            let startIndex = _content.count
            let indexPaths = newElements.enumerate().map({ (index, _) -> NSIndexPath in
                return NSIndexPath(forItem: startIndex + index, inSection: 0)
            })
            
            _content.appendContentsOf(newElements.map{$0 as Any})
            delegate?.dataSource(self, didInsertItemsAtIndexPaths: indexPaths)
        }
    }
    
    public func insert<S>(newElement: S, atIndexPath indexPath: NSIndexPath) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content.insert(newElement, atIndex: indexPath.item)
            delegate?.dataSource(self, didInsertItemsAtIndexPaths: [indexPath])
        }
    }
    
    public func moveElementFromIndexPath(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        editContentWithBlock { (_content, delegate) -> Void in
            let item = _content[fromIndexPath.item]
            _content.removeAtIndex(fromIndexPath.item)
            
            var toIndex = toIndexPath.item
            if toIndexPath.item > fromIndexPath.item {
                toIndex -= 1
            }
            
            _content.insert(item, atIndex: toIndex)
            
            delegate?.dataSource(self, didMoveItemsAtIndexPaths: [fromIndexPath], toIndexPaths: [toIndexPath])
        }
    }
    
    public func removeAtIndexPath(indexPath: NSIndexPath) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content.removeAtIndex(indexPath.item)
            delegate?.dataSource(self, didDeleteItemsAtIndexPaths: [indexPath])
        }
    }
    
    public func remove<S>(element: S) {
        if let indexPath = self.indexPathOf(element) {
            self.removeAtIndexPath(indexPath)
        } else {
            print("Element not found \(element) in dataSource")
        }
    }
    
    public func replaceAtIndexPath<S>(indexPath: NSIndexPath, newElement: S) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content[indexPath.item] = newElement
            delegate?.dataSource(self, didUpdateItemsAtIndexPaths: [indexPath])
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
    left.appendContentsOf(right)
}