//: Playground - noun: a place where people can play

import UIKit



public protocol DataSourceMutableProtocol {
    func addContent(content: AnyObject)
    func addContentFromArray(array: [AnyObject])
    func insertContent(content: AnyObject, atIndexPath indexPath: NSIndexPath)
    
    func moveContentFromIndexPath(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    func removeContentFromIndexPath(indexPath: NSIndexPath)
    func removeContent(content: AnyObject)
}

public protocol DataFeedDelegate {
    func dataFeed(dataFeed: DataFeedProtocol?, failedWithError error: NSError)
    
    func dataFeed(dataFeed: DataFeedProtocol?, didReloadContent content: [AnyObject]?)
    func dataFeed(dataFeed: DataFeedProtocol?, didLoadMoreContent content: [AnyObject]?)
}

public protocol DataSourceIncrementalChangesDelegate {
    func dataSourceWillChangeContent(dataSource: DataSourceProtocol)
    
    func dataSource(dataSource: DataSourceProtocol, didUpdateItemsAtIndexPaths indexPaths: [AnyObject])
    func dataSource(dataSource: DataSourceProtocol, didDeleteItemsAtIndexPaths indexPaths: [AnyObject])
    func dataSource(dataSource: DataSourceProtocol, didInsertItemsAtIndexPaths indexPaths: [AnyObject])
    func dataSource(dataSource: DataSourceProtocol, didMoveItemsAtIndexPaths fromIndexPaths: [AnyObject], toIndexPaths: [AnyObject])
    
    func dataSource(dataSource: DataSourceProtocol, didInsertSections addedSections: NSIndexSet)
    func dataSource(dataSource: DataSourceProtocol, didDeleteSections deletedSections: NSIndexSet)
    func dataSource(dataSource: DataSourceProtocol, didUpdateSections updatedSections: NSIndexSet)
    
    func dataSourceDidChangeContent(dataSource: DataSourceProtocol)
}

public protocol DataSourceDelegate {
    func dataSourceDidReloadContent(dataSource: DataSourceProtocol)
    func dataSourceDidLoadMoreContent(dataSource: DataSourceProtocol)
}

public protocol DataSourceProtocol : DataFeedDelegate {
    
    var content : [AnyObject] { get }
    func hasContent() -> Bool
    func numberOfSections() -> Int
    func numberOfRowsInSection(section: Int) -> Int
    func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject
    
    func indexPathForObject(object: AnyObject) -> NSIndexPath?
    
    var delegate: DataSourceDelegate? { get set }
    var feed: DataFeedProtocol? { get set }
    
    var dataSourceID: String? { get set } //usefull information
}

public protocol DataFeedProtocol {
    
    var delegate: DataFeedDelegate? { get set }
    
    func shouldReload() -> Bool
    
    var canReload: Bool { get } // should be KVO-compliant
    func reload()
    func cancelReload()
    
    var canLoadMore: Bool { get } // should be KVO-compliant
    func loadMore()
    func cancelLoadMore()
    
    var isReloading: Bool { get } // should be KVO-compliant
    var isLoadingMore: Bool { get } // should be KVO-compliant
    
    var lastReloadDate : NSDate? {get}
}

extension DataSource : DataFeedDelegate {
    func dataFeed(dataFeed: DataFeedProtocol?, failedWithError error: NSError) {
        if let delegate = delegate as? DataFeedDelegate {
            delegate.dataFeed(dataFeed, failedWithError: error)
        }
    }
    
    func dataFeed(dataFeed: DataFeedProtocol?, didReloadContent content: [AnyObject]?) {
        // pass delegate message
        if let delegate = delegate as? DataFeedDelegate {
            delegate.dataFeed(dataFeed, didReloadContent: content)
        }
        
        let wasEmpty = content?.isEmpty == true
        _content = content ?? []
        let isEmpty = _content.isEmpty
        
        let incrementalInserts = delegate is DataSourceIncrementalChangesDelegate
        if incrementalInserts {
            let ignore = wasEmpty && isEmpty
            if !ignore {
                let delegate = self.delegate as! DataSourceIncrementalChangesDelegate
                delegate.dataSourceWillChangeContent(self)
                delegate.dataSource(self, didUpdateSections: NSIndexSet(index: 0))
                delegate.dataSourceDidChangeContent(self)
            }
        } else {
            delegate?.dataSourceDidReloadContent(self)
        }
    }
    
    func dataFeed(dataFeed: DataFeedProtocol?, didLoadMoreContent content: [AnyObject]?) {
        // pass delegate message
        if let delegate = delegate as? DataFeedDelegate {
            delegate.dataFeed(dataFeed, didLoadMoreContent: content)
        }
        
        let incrementalInserts = delegate is DataSourceIncrementalChangesDelegate
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
                let delegate = self.delegate as! DataSourceIncrementalChangesDelegate
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

class DataSource : DataSourceProtocol {
    lazy private var _content : [AnyObject] = [AnyObject]()
    
    init(content : [AnyObject]) {
        _content = content
    }
    
    var delegate : DataSourceDelegate?
    var feed : DataFeedProtocol? {
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
    
    var content : [AnyObject] {
        get {
            return _content
        }
    }
    
    func hasContent() -> Bool {
        return _content.isEmpty == false
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return _content.count
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        return _content[indexPath.item]
    }
    
    func indexPathForObject(object: AnyObject) -> NSIndexPath? {
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
    
    var dataSourceID : String?
}

let items = [1, 2, 3, 4, 5]
let dataSource = DataSource(content: items)
dataSource.content
dataSource.hasContent()
dataSource.numberOfSections()
dataSource.numberOfRowsInSection(0)
dataSource.numberOfRowsInSection(0) == items.count
dataSource.objectAtIndexPath(NSIndexPath(forItem: 2, inSection: 0))
dataSource.indexPathForObject(3)?.item

class TestDataSouceDelegate {
    
}

extension TestDataSouceDelegate : DataSourceDelegate {
    func dataSourceDidReloadContent(dataSource: DataSourceProtocol) {
        print(__FUNCTION__)
    }
    
    func dataSourceDidLoadMoreContent(dataSource: DataSourceProtocol) {
        print(__FUNCTION__)
    }
}

let testDelegate = TestDataSouceDelegate()
dataSource.delegate = testDelegate

dataSource.dataFeed(nil, didReloadContent: [1, 2, 3])
dataSource.content
dataSource.dataFeed(nil, didLoadMoreContent: [4,2, 1])
dataSource.content
dataSource.dataFeed(nil, didReloadContent: nil)
dataSource.content
dataSource.dataFeed(nil, didLoadMoreContent: [4, 2, 1])
dataSource.content



extension TestDataSouceDelegate : DataFeedDelegate {
    func dataFeed(dataFeed: DataFeedProtocol?, failedWithError error: NSError) {
        print(__FUNCTION__)
    }
    
    func dataFeed(dataFeed: DataFeedProtocol?, didReloadContent content: [AnyObject]?) {
        print(__FUNCTION__)
    }
    
    func dataFeed(dataFeed: DataFeedProtocol?, didLoadMoreContent content: [AnyObject]?) {
        print(__FUNCTION__)
    }
}


extension DataSource : DataSourceMutableProtocol {
    
    private func editContentWithBlock(editBlock: ( inout content : [AnyObject], delegate: DataSourceIncrementalChangesDelegate?)->Void) {
        let incrementalUpdates = delegate is DataSourceIncrementalChangesDelegate
        if (incrementalUpdates) {
            let delegate = self.delegate as! DataSourceIncrementalChangesDelegate
            delegate.dataSourceWillChangeContent(self)
            editBlock(content: &_content, delegate: delegate);
            delegate.dataSourceDidChangeContent(self)
        } else {
            editBlock(content: &_content, delegate: nil);
            delegate?.dataSourceDidReloadContent(self)
        }
    }
    
    func addContent(content: AnyObject) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content.append(content)
            let indexPath = NSIndexPath(forItem: _content.count, inSection: 0)
            delegate?.dataSource(self, didInsertItemsAtIndexPaths: [indexPath])
        }
    }
    
    func addContentFromArray(array: [AnyObject]) {
        editContentWithBlock { (_content, delegate) -> Void in
            let startIndex = _content.count
            let indexPaths = array.enumerate().map({ (index, _) -> NSIndexPath in
                return NSIndexPath(forItem: startIndex + index, inSection: 0)
            })
            
            _content.appendContentsOf(array)
            delegate?.dataSource(self, didInsertItemsAtIndexPaths: indexPaths)
        }
    }
    
    func insertContent(content: AnyObject, atIndexPath indexPath: NSIndexPath) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content.insert(content, atIndex: indexPath.item)
            delegate?.dataSource(self, didInsertItemsAtIndexPaths: [indexPath])
        }
    }
    
    func moveContentFromIndexPath(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
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
    
    func removeContentFromIndexPath(indexPath: NSIndexPath) {
        editContentWithBlock { (_content, delegate) -> Void in
            _content.removeAtIndex(indexPath.item)
            delegate?.dataSource(self, didDeleteItemsAtIndexPaths: [indexPath])
        }
    }
    
    func removeContent(content: AnyObject) {
        if let indexPath = self.indexPathForObject(content) {
            self.removeContentFromIndexPath(indexPath)
        } else {
            print("Content not found \(content) in dataSource")
        }
    }
}

dataSource.content
dataSource.addContent(4)
dataSource.content
dataSource.addContent("test")
dataSource.content
dataSource.removeContent("test1")
dataSource.removeContent(4)
dataSource.content
dataSource.insertContent(5, atIndexPath: NSIndexPath(forItem: 0, inSection: 0))
dataSource.content
dataSource.moveContentFromIndexPath(NSIndexPath(forItem: 4, inSection: 0), toIndexPath: NSIndexPath(forItem: 0, inSection: 0))
dataSource.content
dataSource.moveContentFromIndexPath(NSIndexPath(forItem: 0, inSection: 0), toIndexPath: NSIndexPath(forItem: 4, inSection: 0))
dataSource.content
dataSource.addContentFromArray([7, 8])
dataSource.content


//public class TTDataFeed : NSObject, TTDataFeedProtocol {
//
//    public func loadMoreOperationWithCallback(callback: ((AnyObject!, NSError!) -> Void)!) -> NSOperation!
//    public func reloadOperationWithCallback(callback: ((AnyObject!, NSError!) -> Void)!) -> NSOperation!
//}









protocol test {
    func name(object: AnyObject) -> String
}

class Testing<Type> : test {
    func name(object: Type) -> String {
        return __FUNCTION__ + "1"
    }
    
    func name(object: AnyObject) -> String {
        if let dd = object as? Type {
            return name(dd)
        } else {
            return __FUNCTION__ + "2"
        }
    }
}

let item = Testing<String>()
item.name(1)
item.name("23")

let item1 = "23" as AnyObject
item.name(item1)

protocol TestingType {
    func accept(object:AnyObject) -> Bool
}

protocol TestingSpecificType : TestingType {
    typealias NewType
    
    func accept(object:NewType) -> Bool
}

extension TestingSpecificType {
    func accept(object: AnyObject) -> Bool {
        return accept(object as! NewType)
    }
    
    func accept(object: NewType) -> Bool {
        return true
    }
}

class SpecificType : TestingSpecificType {
    typealias NewType = String
}

let spefic = SpecificType()
let aaa = "rer" as AnyObject
spefic.accept("")
spefic.accept(aaa)
