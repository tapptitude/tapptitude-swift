//
//  DataSourceProtocol.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

public protocol TTAnyDataSource : TTDataFeedDelegate, CustomStringConvertible {
    
    var isEmpty: Bool { get }
    func numberOfSections() -> Int
    func numberOfItems(inSection section: Int) -> Int
    
    func item(at indexPath: IndexPath) -> Any
    
    weak var delegate: TTDataSourceDelegate? { get set }
    var feed: TTDataFeed? { get set }
    
    var dataSourceID: String? { get set } //usefull information
    
    func indexPath<S>(ofFirst filter: (_ item: S) -> Bool) -> IndexPath?
    
    func sectionHeaderItem(at section: Int) -> Any?
    var content_ : [Any] { get }
}

public protocol TTDataSource : TTAnyDataSource {
    associatedtype ContentType
    
    subscript(indexPath: IndexPath) -> ContentType { get }
}

extension TTDataSource {
    subscript(section: Int, index: Int) -> ContentType {
        return self[IndexPath(item: index, section: section)]
    }
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
    func dataSourceWillChangeContent(_ dataSource: TTAnyDataSource)
    
    func dataSource(_ dataSource: TTAnyDataSource, didUpdateItemsAt indexPaths: [IndexPath])
    func dataSource(_ dataSource: TTAnyDataSource, didDeleteItemsAt indexPaths: [IndexPath])
    func dataSource(_ dataSource: TTAnyDataSource, didInsertItemsAt indexPaths: [IndexPath])
    func dataSource(_ dataSource: TTAnyDataSource, didMoveItemsFrom fromIndexPaths: [IndexPath], to toIndexPaths: [IndexPath])
    
    func dataSource(_ dataSource: TTAnyDataSource, didInsertSections addedSections: IndexSet)
    func dataSource(_ dataSource: TTAnyDataSource, didDeleteSections deletedSections: IndexSet)
    func dataSource(_ dataSource: TTAnyDataSource, didUpdateSections updatedSections: IndexSet)
    
    func dataSourceDidChangeContent(_ dataSource: TTAnyDataSource)
}


public enum CellPositionInSection {
    case top
    case middle
    case bottom
    case single
}

extension TTAnyDataSource {
    public  func itemPositionInSection(for indexPath: IndexPath) -> CellPositionInSection {
        let count = numberOfItems(inSection: indexPath.section)
        
        switch (count, indexPath.item) {
        case (1, _):
            return .single
        case (_, 0):
            return .top
        case (_, count-1):
            return .bottom
        default:
            return .middle
        }
    }
}


extension TTAnyDataSource {
    public var description: String {
        return String(describing: type(of: self)) + ": " + content_.description
    }
    
    public func item(at item: Int, section: Int) -> Any {
        return self.item(at: IndexPath(item: item, section: section))
    }
}
