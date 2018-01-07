//
//  FetchedDataSource.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 2/6/13.
//  Copyright © 2013 Tapptitude. All rights reserved.
//

import Foundation
import CoreData

struct FetchedDataSourceInfo {
    static let didReloadNotification = NSNotification.Name(rawValue: "FetchedDataSourceDidReloadNotification")
}

class FetchedDataSource<T: NSManagedObject>: NSObject, TTDataSource, NSFetchedResultsControllerDelegate, TTDataFeedDelegate {
    
    open var fetchController: NSFetchedResultsController<T>
    open var returnValueAtKey: String?
    
    open weak var delegate: TTDataSourceDelegate?
    
    open var dataSourceID: String? { //usefull information
        didSet { updateTrackReloadDataSourceNotifications() }
    }
    
    init (fetchRequest: NSFetchRequest<T>, sectionKeyPath: String? = nil, context: NSManagedObjectContext, cacheName: String? = nil) {
        fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionKeyPath, cacheName: cacheName)
        super.init()
        performFetch()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.fetchController.delegate = nil
        self.feed?.delegate = nil
    }
    
    open var isEmpty: Bool {
        return fetchController.fetchedObjects!.isEmpty
    }
    
    open var content: [T]  {
        let content = fetchController.fetchedObjects ?? []
        if let key = returnValueAtKey {
            return content.map({ $0.value(forKey: key) as! T })
        } else {
            return content
        }
    }
    
    open var content_: [Any]  {
        return content
    }
    
    public var predicate: NSPredicate? {
        set { fetchController.fetchRequest.predicate = newValue }
        get { return fetchController.fetchRequest.predicate }
    }
    
    public func performFetch() {
        try! self.fetchController.performFetch()
    }
    
    public var trackManagedObjectChanges: Bool {
        get { return fetchController.delegate === self }
        set {
            self.fetchController.delegate = newValue ? self : nil
            self.updateTrackReloadDataSourceNotifications()
        }
    }
    
    open var feed : TTDataFeed? {
        willSet { feed?.delegate = nil }
        didSet { feed?.delegate = self }
    }
    
//MARK: - TTDataSource
    
    open subscript(indexPath: IndexPath) -> T {
        let object = fetchController.object(at: indexPath)
        if let key = returnValueAtKey {
            return object.value(forKey: key) as! T
        }
        
        return object
    }
    
    open func item(at indexPath: IndexPath) -> Any {
        return self[indexPath]
    }
    
    open func indexPath<S>(ofFirst filter: (_ item: S) -> Bool) -> IndexPath? {
        return nil
    }
    
    open func indexPath(for object: T) -> IndexPath? {
        return fetchController.indexPath(forObject: object)
    }
    
    open func numberOfSections() -> Int {
        return fetchController.sections?.count ?? 0
    }
    
    open func numberOfItems(inSection section: Int) -> Int {
        let sectionInfo = self.fetchController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    public var sectionHeaders: [Any]?
    open func sectionHeaderItem(at section: Int) -> Any? {
        return sectionHeaders?[section] ?? self.fetchController.sections![section]
    }
    
    //MARK: - NSFetchedResultsControllerDelegate
    open func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataSourceWillChangeContent(self)
    }
    
    open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            self.delegate?.dataSource(self, didInsertSections: IndexSet(integer: sectionIndex))
        case .delete:
            self.delegate?.dataSource(self, didDeleteSections: IndexSet(integer: sectionIndex))
        case .move, .update:
            break
        }
    }

    open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            delegate?.dataSource(self, didInsertItemsAt: [newIndexPath!])
        case .delete:
            delegate?.dataSource(self, didInsertItemsAt: [indexPath!])
        case .update:
            delegate?.dataSource(self, didUpdateItemsAt: [indexPath!])
        case .move:
            delegate?.dataSource(self, didDeleteItemsAt: [indexPath!])
            delegate?.dataSource(self, didInsertItemsAt: [newIndexPath!])
        }
    }
    
    open func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataSourceDidChangeContent(self)
    }
    
    
    //MARK: - TTDataFeedDelegate
    open func dataFeed(_ dataFeed: TTDataFeed?, stateChangedFrom fromState: FeedState, toState: FeedState) {
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, stateChangedFrom: fromState, toState: toState)
        }
    }
    
    open func dataFeed(_ dataFeed: TTDataFeed?, didLoadResult result: Result<[Any]>, forState: FeedState.Load) {
        // pass delegate message
        if let delegate = delegate as? TTDataFeedDelegate {
            delegate.dataFeed(dataFeed, didLoadResult: result, forState: forState)
        }
        
        guard result.isSuccess else {
            return
        }
        
        switch forState {
        case .reloading, .loadingMore:
            if trackManagedObjectChanges {
                // delegate will be notified trough insert/delete/move changes
            } else {
                performFetch()
                delegate?.dataSourceDidChangeContent(self)
            }
            
            let postToOtherDataSourcesWithSameID = self.dataSourceID != nil && dataFeed != nil
            if postToOtherDataSourcesWithSameID {
                NotificationCenter.default.post(name: FetchedDataSourceInfo.didReloadNotification, object: nil)
            }
        }
    }
    
    //MARK: - Post DataSource reload notification (other DataSource can be up to date)
    open func updateTrackReloadDataSourceNotifications() {
        NotificationCenter.default.removeObserver(self, name: FetchedDataSourceInfo.didReloadNotification, object: nil)
        
        let shouldTrack = !trackManagedObjectChanges && self.dataSourceID != nil
        if shouldTrack {
            NotificationCenter.default.addObserver(self, selector: #selector(dataSourceContentChanged(notification:)), name: FetchedDataSourceInfo.didReloadNotification, object: nil)
        }
    }
    
    @objc func dataSourceContentChanged(notification: NSNotification) {
        let otherDataSource = notification.object as? TTAnyDataSource
        if self === otherDataSource || !(otherDataSource?.dataSourceID == self.dataSourceID) {
            return
        }
        
        self.performFetch()
        delegate?.dataSourceDidChangeContent(self)
    }
}
