//
//  DataSource.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation


public class DataSource : TTDataSource {
    lazy private var _content : [AnyObject] = [AnyObject]()
    
    public init(content : [AnyObject]) {
        _content = content
    }
    
    public var delegate : TTDataSourceDelegate?
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
    
    public var content : [AnyObject] {
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
    
    public func numberOfRowsInSection(section: Int) -> Int {
        return _content.count
    }
    
    public func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        return _content[indexPath.item]
    }
    
    public func indexPathForObject(object: AnyObject) -> NSIndexPath? {
        // TODO: find a better way
        let index = _content.indexOf({ (arrayObject) -> Bool in
            return arrayObject === object
        })
        
        if index != nil {
            return NSIndexPath(forItem: index!, inSection: 0)
        } else {
            return nil
        }
    }
    
    public var dataSourceID : String?
}


public protocol TTDataSourceIncrementalChangesDelegate {
    func dataSourceWillChangeContent(dataSource: TTDataSource)
    
    func dataSource(dataSource: TTDataSource, didUpdateItemsAtIndexPaths indexPaths: [AnyObject])
    func dataSource(dataSource: TTDataSource, didDeleteItemsAtIndexPaths indexPaths: [AnyObject])
    func dataSource(dataSource: TTDataSource, didInsertItemsAtIndexPaths indexPaths: [AnyObject])
    func dataSource(dataSource: TTDataSource, didMoveItemsAtIndexPaths fromIndexPaths: [AnyObject], toIndexPaths: [AnyObject])
    
    func dataSource(dataSource: TTDataSource, didInsertSections addedSections: NSIndexSet)
    func dataSource(dataSource: TTDataSource, didDeleteSections deletedSections: NSIndexSet)
    func dataSource(dataSource: TTDataSource, didUpdateSections updatedSections: NSIndexSet)
    
    func dataSourceDidChangeContent(dataSource: TTDataSource)
}


extension DataSource : TTDataFeedDelegate {
    public func dataFeed(dataFeed: TTDataFeed?, failedWithError error: NSError) {
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, failedWithError: error)
        }
    }
    
    public func dataFeed(dataFeed: TTDataFeed?, didReloadContent content: [AnyObject]?) {
        // pass delegate message
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, didReloadContent: content)
        }
        
        let wasEmpty = content?.isEmpty == true
        _content = content ?? []
        let isEmpty = _content.isEmpty
        
        let incrementalInserts = delegate is TTDataSourceIncrementalChangesDelegate
        if incrementalInserts {
            let ignore = wasEmpty && isEmpty
            if !ignore {
                let delegate = self.delegate as! TTDataSourceIncrementalChangesDelegate
                delegate.dataSourceWillChangeContent(self)
                delegate.dataSource(self, didUpdateSections: NSIndexSet(index: 0))
                delegate.dataSourceDidChangeContent(self)
            }
        } else {
            delegate?.dataSourceDidReloadContent(self)
        }
    }
    
    public func dataFeed(dataFeed: TTDataFeed?, didLoadMoreContent content: [AnyObject]?) {
        // pass delegate message
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, didLoadMoreContent: content)
        }
        
        let incrementalInserts = delegate is TTDataSourceIncrementalChangesDelegate
        var indexPaths = [NSIndexPath]();
        
        if let content = content {
            _content.appendContentsOf(content)
            
            if incrementalInserts {
                indexPaths = content.enumerate().map({ (index, _) -> NSIndexPath in
                    return NSIndexPath(forItem: index, inSection: 0)
                })
            }
        }
        
        if incrementalInserts {
            if !indexPaths.isEmpty {
                let delegate = self.delegate as! TTDataSourceIncrementalChangesDelegate
                delegate.dataSourceWillChangeContent(self)
                delegate.dataSource(self, didInsertItemsAtIndexPaths: indexPaths)
                delegate.dataSourceDidChangeContent(self)
            }
        } else if (content?.isEmpty == false){
            delegate?.dataSourceDidLoadMoreContent(self)
        } else {
            // no content loaded
        }
    }
}



extension DataSource : TTDataSourceMutable {
    
    private func editContentWithBlock(editBlock: ( inout content : [AnyObject], delegate: TTDataSourceIncrementalChangesDelegate?)->Void) {
        let incrementalUpdates = delegate is TTDataSourceIncrementalChangesDelegate
        if (incrementalUpdates) {
            let delegate = self.delegate as! TTDataSourceIncrementalChangesDelegate
            delegate.dataSourceWillChangeContent(self)
            editBlock(content: &_content, delegate: delegate);
            delegate.dataSourceDidChangeContent(self)
        } else {
            editBlock(content: &_content, delegate: nil);
            delegate?.dataSourceDidReloadContent(self)
        }
    }
    
    public func addContent(content: AnyObject) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content.append(content)
            let indexPath = NSIndexPath(forItem: _content.count, inSection: 0)
            delegate?.dataSource(self, didInsertItemsAtIndexPaths: [indexPath])
        }
    }
    
    public func addContentFromArray(array: [AnyObject]) {
        editContentWithBlock { (_content, delegate) -> Void in
            let startIndex = _content.count
            let indexPaths = array.enumerate().map({ (index, _) -> NSIndexPath in
                return NSIndexPath(forItem: startIndex + index, inSection: 0)
            })
            
            _content.appendContentsOf(array)
            delegate?.dataSource(self, didInsertItemsAtIndexPaths: indexPaths)
        }
    }
    
    public func insertContent(content: AnyObject, atIndexPath indexPath: NSIndexPath) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content.insert(content, atIndex: indexPath.item)
            delegate?.dataSource(self, didInsertItemsAtIndexPaths: [indexPath])
        }
    }
    
    public func moveContentFromIndexPath(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
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
    
    public func removeContentFromIndexPath(indexPath: NSIndexPath) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content.removeAtIndex(indexPath.item)
            delegate?.dataSource(self, didDeleteItemsAtIndexPaths: [indexPath])
        }
    }
    
    public func removeContent(content: AnyObject) {
        if let indexPath = self.indexPathForObject(content) {
            self.removeContentFromIndexPath(indexPath)
        } else {
            print("Content not found \(content) in dataSource")
        }
    }
}