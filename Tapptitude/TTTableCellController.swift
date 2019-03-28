//
//  TTTableCellController.swift
//  Tapptitude
//
//  Created by Ion Toderasco on 11/11/2018.
//  Copyright © 2018 Tapptitude. All rights reserved.
//

import UIKit

public protocol TTAnyTableCellController: class {
    
    func acceptsContent(_ content: Any) -> Bool
    
    func classToInstantiateCell(for content: Any) -> AnyClass?
    
    func nibToInstantiateCell(for content: Any) -> UINib?
    
    func reuseIdentifier(for content: Any) -> String
    
    func configureCell(_ cell: UITableViewCell, for content: Any, at indexPath: IndexPath)
    
    func didSelectContent(_ content: Any, at indexPath: IndexPath, in tableView: UITableView)
    
    
    var parentViewController: UIViewController? { get set }
    
    var cellHeight: CGFloat { get }
    var estimatedRowHeight: CGFloat { get }
    
    func cellHeight(for content: Any, in tableView: UITableView) -> CGFloat
    
    func allSupportedReuseIdentifiers() -> [String]
}

extension TTTableCellController {
    public var dataSource: TTAnyDataSource? {
        return (self.parentViewController as? TTTableFeedController)?._dataSource
    }
}

public protocol TTTableCellController: TTAnyTableCellController {
    
    associatedtype ContentType
    associatedtype CellType: UITableViewCell
    
    func classToInstantiateCell(for content: ContentType) -> AnyClass?
    func nibToInstantiateCell(for content: ContentType) -> UINib?
    
    func reuseIdentifier(for content: ContentType) -> String
    
    func configureCell(_ cell: CellType, for content: ContentType, at indexPath: IndexPath)
    
    func didSelectContent(_ content: ContentType, at indexPath: IndexPath, in tableView: UITableView)
    
    func cellHeight(for content: ContentType, in tableView: UITableView) -> CGFloat
}

public protocol TTTableCellControllerSize: TTTableCellController {
    
    var sizeCalculationCell: CellType! { get }
    
    func cellHeightToFit(text: String, label: UILabel, maxHeight: CGFloat) -> CGFloat
    func cellHeightToFit(attributedText: NSAttributedString, label: UILabel, maxHeight: CGFloat) -> CGFloat
}

extension TTTableCellControllerSize {
    
    public func cellHeightToFit(text: String, label: UILabel, maxHeight: CGFloat = 2040) -> CGFloat {
        var size = sizeCalculationCell.bounds.size
        var maxHeight = maxHeight
        
        label.text = text
        
        assert(label.lineBreakMode == .byWordWrapping, "Label line break mode should be NSLineBreakByWordWrapping")
        assert(label.numberOfLines != 1, "Label number of lines should be set to 0")
        maxHeight = label.bounds.size.height
        let labelSize = CGSize(width: label.bounds.size.width, height: maxHeight)
        let newLabelSize = label.sizeThatFits(labelSize)
        size.height += newLabelSize.height - label.bounds.size.height

        return size.height
    }
    
    public func cellHeightToFit(attributedText: NSAttributedString, label: UILabel, maxHeight: CGFloat = 2040) -> CGFloat {
        var size = sizeCalculationCell.bounds.size
        
        label.attributedText = attributedText
        
        assert(label.lineBreakMode == .byWordWrapping, "Label line break mode should be NSLineBreakByWordWrapping")
        let labelSize = CGSize(width: label.bounds.size.width, height: maxHeight)
        let newLabelSize = label.sizeThatFits(labelSize)
        size.height += newLabelSize.height - label.bounds.size.height
        
        return size.height
    }
}

extension TTTableCellController {
    
    public func classToInstantiateCell(for content: Any) -> AnyClass? {
        return classToInstantiateCell(for: content as! ContentType)
    }
    
    public func nibToInstantiateCell(for content: Any) -> UINib? {
        return nibToInstantiateCell(for: content as! ContentType)
    }
    
    public func reuseIdentifier(for content: Any) -> String {
        return reuseIdentifier(for: content as! ContentType)
    }
    
    public func configureCell(_ cell: UITableViewCell, for content: Any, at indexPath: IndexPath) {
        configureCell(cell as! CellType, for: content as! ContentType, at: indexPath)
    }
    
    public func didSelectContent(_ content: Any, at indexPath: IndexPath, in tableView: UITableView) {
        didSelectContent(content as! ContentType, at: indexPath, in: tableView)
    }
    
    public func cellHeight(for content: Any, in tableView: UITableView) -> CGFloat {
        return cellHeight(for: content as! ContentType, in: tableView)
    }
}
