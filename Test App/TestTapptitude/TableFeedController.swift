//
//  TableFeedController.swift
//  TestTapptitude
//
//  Created by Alexandru Tudose on 14/11/2018.
//  Copyright © 2018 Tapptitude. All rights reserved.
//

import UIKit
import Tapptitude

class TestTableViewController : __TableFeedController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self._cellController = MultiTableCellController(TextTableCellController(), FixCellController())
        self._dataSource = DataSource<Any>(loadPage: API.getTableDummyContent(offset:callback:))

        addPullToRefresh()

        let removeB = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(remove))
        let addB = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(add))

        navigationItem.rightBarButtonItems = [removeB, addB]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc func remove() {
        if let lastIndex = dataSource.lastIndexPath {
            dataSource.remove(at: [lastIndex])
        }
    }

    @objc func add() {
        let lastIndex = dataSource.lastIndexPath ?? IndexPath(row: 0, section: 0)
        dataSource.insert(contentsOf: [lastIndex.row + 1, lastIndex.row + 2], at: lastIndex)
        tableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
    }

    open var dataSource: DataSource<Any> {
        get { return _dataSource as! DataSource<Any> }
        set { _dataSource = newValue }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.dataSource.remove(at: indexPath)
        }

        let share = UITableViewRowAction(style: .normal, title: "Insert after") { (action, indexPath) in
            let newIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            self.dataSource.insert(contentsOf: ["test"], at: newIndexPath)
        }

        share.backgroundColor = UIColor.blue

        return [delete, share]
    }
}
