//
//  TableCellController.swift
//  Tapptitude
//
//  Created by Ion Toderasco on 11/11/2018.
//  Copyright © 2018 Tapptitude. All rights reserved.
//

import UIKit

open class TableCellController<ContentName, CellName: UITableViewCell>: TTTableCellController, TTTableCellControllerSize {
    
    public typealias ContentType = ContentName
    public typealias CellType = CellName
    
    open var cellHeightForContent: ((_ content: ContentType, _ tableView: UITableView) -> CGFloat)?
    open var configureCell: ((_ cell: CellType, _ content: ContentType, _ indexPath: IndexPath) -> Void)?
    open var didSelectContent: ((_ content: ContentType, _ indexPath: IndexPath, _ tableView: UITableView) -> Void)?
    
    open var sectionInset = UIEdgeInsets.zero
    open var cellHeight: CGFloat
    open var reuseIdentifier: String
    
    open weak var parentViewController: UIViewController?
    
    public init(cellHeight: CGFloat = UITableView.automaticDimension, reuseIdentifier: String = String(describing: CellType.self)) {
        self.cellHeight = cellHeight
        self.reuseIdentifier = reuseIdentifier
    }
    
    
    open func cellHeight(for content: ContentType, in tableView: UITableView) -> CGFloat {
        let blockHeight = cellHeightForContent?(content, tableView)
        return blockHeight ?? cellHeight
    }
    
    open func configureCell(_ cell: CellType, for content: ContentType, at indexPath: IndexPath) {
        configureCell?(cell, content, indexPath)
    }
    
    open func didSelectContent(_ content: ContentType, at indexPath: IndexPath, in tableView: UITableView) {
        didSelectContent?(content, indexPath, tableView)
    }
    
    var _sizeCalculationCell: CellType!
    
    open var sizeCalculationCell: CellType! {
        //TODO:
        return _sizeCalculationCell!
    }
    
    
    open func acceptsContent(_ content: Any) -> Bool {
        if let content = content as? ContentType {
            return acceptsContent(content)
        } else {
            return false
        }
    }
    
    open func acceptsContent(_ content: ContentType) -> Bool {
        return true
    }
    
    open func nibToInstantiateCell() -> UINib? {
        return nibToInstantiateCell(reuseIdentifier: reuseIdentifier)
    }
    
    open func nibToInstantiateCell(for content: ContentType) -> UINib? {
        let reuseIdentifier = self.reuseIdentifier(for: content)
        return nibToInstantiateCell(reuseIdentifier: reuseIdentifier)
    }
    
    open func nibToInstantiateCell(reuseIdentifier: String) -> UINib? {
        if let _ = Bundle(for: CellType.self).path(forResource: reuseIdentifier, ofType: "nib") {
            return UINib(nibName: reuseIdentifier, bundle: Bundle(for: CellType.self))
        } else {
            return nil
        }
    }
    
    open func reuseIdentifier(for content: ContentType) -> String {
        return reuseIdentifier
    }
    
    open func allSupportedReuseIdentifiers() -> [String] {
        return [reuseIdentifier]
    }
    
    open func classToInstantiateCell(for content: ContentType) -> AnyClass? {
        return CellType.self
    }
    
    open func sectionInset(for content: ContentType, in tableView: UITableView) -> UIEdgeInsets {
        return sectionInset
    }
}

extension UITableViewCell {
    
    fileprivate struct AssociatedKey {
        static var viewExtension = "viewExtension"
    }
    
    public var parentViewController: UIViewController? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.viewExtension) as? UIViewController ?? nil
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.viewExtension, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
