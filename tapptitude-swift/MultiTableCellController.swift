//
//  MultiTableCellController.swift
//  Tapptitude
//
//  Created by Ion Toderasco on 18/11/2018.
//  Copyright © 2018 Tapptitude. All rights reserved.
//

import UIKit

open class MultiTableCellController: TTTableCellController {

    public init(_ cellControllers: [TTAnyTableCellController]) {
        self.cellControllers = cellControllers
    }
    
    public init(_ cellControllers: TTAnyTableCellController...) {
        self.cellControllers = cellControllers
    }
    
    public convenience required init(arrayLiteral elements: TTAnyTableCellController...) {
        self.init(elements.map({ $0 }))
    }
    
    open var cellControllers: [TTAnyTableCellController] = [] {
        willSet {
            for cellController in cellControllers {
                cellController.parentViewController = nil
            }
            previousCellController = nil
        }
        
        didSet {
            for cellController in cellControllers {
                cellController.parentViewController = parentViewController
            }
        }
    }
    
    fileprivate var previousCellController: TTAnyTableCellController?
    
    open func controllerForContent(_ content: Any) -> TTAnyTableCellController? {
        if previousCellController?.acceptsContent(content) == true {
            return previousCellController
        }

        for cellController in cellControllers {
            if cellController.acceptsContent(content) == true {
                previousCellController = cellController
                return cellController
            }
        }
        
        return nil
    }
    
    open weak var parentViewController: UIViewController? {
        didSet {
            for cellController in cellControllers {
                cellController.parentViewController = parentViewController
            }
        }
    }
    
    open var cellHeight = UITableView.automaticDimension
    open var sectionInset = UIEdgeInsets.zero
    
    public func acceptsContent(_ content: Any) -> Bool {
        return controllerForContent(content) != nil
    }
    
    open func classToInstantiateCell(for content: Any) -> AnyClass? {
        return controllerForContent(content)?.classToInstantiateCell(for: content)
    }
    
    open func nibToInstantiateCell(for content: Any) -> UINib? {
        return controllerForContent(content)?.nibToInstantiateCell(for: content)
    }
    
    open func reuseIdentifier(for content: Any) -> String {
        return controllerForContent(content)!.reuseIdentifier(for: content)
    }
    
    open func configureCell(_ cell: UITableViewCell, for content: Any, at indexPath: IndexPath) {
        controllerForContent(content)!.configureCell(cell, for: content, at: indexPath)
    }
    
    open func didSelectContent(_ content: Any, at indexPath: IndexPath, in tableView: UITableView) {
        controllerForContent(content)!.didSelectContent(content, at: indexPath, in: tableView)
    }
    
    public func cellHeight(for content: Any, in tableView: UITableView) -> CGFloat {
        return controllerForContent(content)!.cellHeight(for: content, in: tableView)
    }
    
    open func allSupportedReuseIdentifiers() -> [String] {
        var allReuseIdentifiers: [String] = []
        cellControllers.forEach{ allReuseIdentifiers += $0.allSupportedReuseIdentifiers() }
        return allReuseIdentifiers
    }
    
}

extension MultiTableCellController: ExpressibleByArrayLiteral {
    
}
