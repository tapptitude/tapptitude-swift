//
//  DataSourceProtocol.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public protocol TTDataSource : TTDataFeedDelegate, CustomStringConvertible {
    
    var content : [Any] { get }
    var isEmpty: Bool { get }
    func numberOfSections() -> Int
    func numberOfItems(inSection section: Int) -> Int
    
    subscript(indexPath: IndexPath) -> Any { get }
    subscript(section: Int, index: Int) -> Any { get }
    
    weak var delegate: TTDataSourceDelegate? { get set }
    var feed: TTDataFeed? { get set }
    
    var dataSourceID: String? { get set } //usefull information
    
    func indexPath<S>(ofFirst filter: (_ item: S) -> Bool) -> IndexPath?
    
    func sectionHeaderItem(at section: Int) -> Any?
}




public protocol TTDataSourceMutable {
    associatedtype Element
    
    func append(_ newElement: Element)
    func append(contentsOf newElements: [Element])

    func insert(_ newElement: Element, at indexPath: IndexPath)
    func insert(contentsOf newElements: [Element], at indexPath: IndexPath)
    
    func moveElement(from fromIndexPath: IndexPath, to toIndexPath: IndexPath)
    func remove(at indexPaths: [IndexPath])
    func remove(at indexPath: IndexPath)
    func remove(_ filter: (_ item: Element) -> Bool)
    
    subscript(indexPath: IndexPath) -> Element { get set }
    subscript(section: Int, index: Int) -> Element { get set }
}

extension TTDataSourceMutable where Element == Any {
    public func append<S>(contentsOf newElements: [S]) {
        append(contentsOf: newElements.map{$0 as Any})
    }
    
    public func insert<S>(contentsOf newElements: [S], at indexPath: IndexPath) {
        insert(contentsOf: newElements.map({$0 as Any}), at: indexPath)
    }
}


public protocol TTDataSourceDelegate: class {
    func dataSourceWillChangeContent(_ dataSource: TTDataSource)
    
    func dataSource(_ dataSource: TTDataSource, didUpdateItemsAt indexPaths: [IndexPath])
    func dataSource(_ dataSource: TTDataSource, didDeleteItemsAt indexPaths: [IndexPath])
    func dataSource(_ dataSource: TTDataSource, didInsertItemsAt indexPaths: [IndexPath])
    func dataSource(_ dataSource: TTDataSource, didMoveItemsFrom fromIndexPaths: [IndexPath], to toIndexPaths: [IndexPath])
    
    func dataSource(_ dataSource: TTDataSource, didInsertSections addedSections: IndexSet)
    func dataSource(_ dataSource: TTDataSource, didDeleteSections deletedSections: IndexSet)
    func dataSource(_ dataSource: TTDataSource, didUpdateSections updatedSections: IndexSet)
    
    func dataSourceDidChangeContent(_ dataSource: TTDataSource)
}


extension TTDataSource {
    public var description: String {
        return String(describing: type(of: self)) + ": " + content.description
    }
}
