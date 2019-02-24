//
//  TTTableFeedController.swift
//  Tapptitude
//
//  Created by Ion Toderasco on 11/11/2018.
//  Copyright © 2018 Tapptitude. All rights reserved.
//

import UIKit

public protocol TTTableFeedController: class, UITableViewDelegate, UITableViewDataSource {
    
    var _dataSource: TTAnyDataSource? { get set }
    var _cellController: TTAnyTableCellController! { get set }
    
    var tableView: UITableView! { get set }
    
    var reloadIndicatorView: UIActivityIndicatorView? {get set}
    var emptyView: UIView? {get set} //set from XIB or overwrite
    
    /* Pull to Refresh functionality */
    var refreshControl: UIRefreshControl? { get set }
    func pullToRefreshAction(_ sender: AnyObject!)
    func addPullToRefresh()
    
    var loadMoreController: TableLoadMoreController? { get set }
    
    /* Helpers */
    func scrollToElement<T>(ofFirst filter: (_ item: T) -> Bool, animated: Bool)
}

extension TTTableFeedController {
    
    public func scrollToElement<T>(ofFirst filter: (_ item: T) -> Bool, animated: Bool) {
        guard let indexPath = _dataSource!.indexPath(ofFirst: filter) else {
            return
        }
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }
}
