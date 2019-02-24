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
        self._dataSource = DataSource(["abc", 2, "a", 3, 5])

//        self._dataSource = MSDataSource([[2,3],[6]])

        addPullToRefresh()

        let removeB = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(remove))
        let addB = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(add))

        navigationItem.rightBarButtonItems = [removeB, addB]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc func remove() {
        let lastIndex = dataSource.lastIndexPath!
        let companyNameIndex = IndexPath(row: lastIndex.row-2, section: 0)
        let insuranceNumberIndex = IndexPath(row: lastIndex.row-1, section: 0)
        dataSource.remove(at: [companyNameIndex, insuranceNumberIndex])
    }

    @objc func add() {
        let lastIndex = dataSource.lastIndexPath!
        dataSource.insert(contentsOf: [7, 8], at: lastIndex)
        tableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
    }

    open var dataSource: DataSource<Any> {
        get { return _dataSource as! DataSource<Any> }
        set { _dataSource = newValue }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
        }

        let share = UITableViewRowAction(style: .normal, title: "Disable") { (action, indexPath) in
            // share item at indexPath
        }

        share.backgroundColor = UIColor.blue

        return [delete, share]
    }
}


open class MSDataSource<T>: TTDataSource {

    public var dataSourceID: String?

    public func indexPath<S>(ofFirst filter: (S) -> Bool) -> IndexPath? {
        return nil
    }

    public func dataFeed(_ dataFeed: TTDataFeed?, stateChangedFrom fromState: FeedState, toState: FeedState) {

    }

    public func dataFeed(_ dataFeed: TTDataFeed?, didLoadResult result: Result<[Any]>, forState: FeedState.Load) {

    }


    public typealias Element = T

    lazy fileprivate var _content: [Array<T>] = [Array<T>]()

    public init(_ sections: [Array<T>]) {
        _content = sections
    }

    public init(_ content: NSArray) {
        _content = content.map({$0 as! Array<T>})
    }

    public init() {
        _content = []
    }

    open weak var delegate: TTDataSourceDelegate?

    open var feed: TTDataFeed? {
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

    open var content_ : [Any] {
        return content
    }

    open var content: [Array<T>] {
        return _content
    }

    open var isEmpty: Bool {
        return _content.isEmpty
    }

    open func numberOfSections() -> Int {
        return _content.count
    }

    open func numberOfItems(inSection section: Int) -> Int {
        return _content[section].count
    }

    open func indexPath<S>(ofFirst filter: (_ item: S) -> Bool, inSection section: Int) -> IndexPath? {
        guard section < numberOfSections() else {
            return nil
        }

        let index = _content[section].index { (item) -> Bool in
            if let item = item as? S {
                return filter(item)
            } else {
                return false
            }
        }

        return index != nil ? IndexPath(item: index!, section: section) : nil
    }

    open func indexPath(where predicate: (T) -> Bool, inSection section: Int) -> IndexPath? {
        guard section < numberOfSections() else {
            return nil
        }
        return _content[section].index(where: predicate).map({ IndexPath(item: $0, section: section) })
    }

    open func item(at indexPath: IndexPath) -> Any {
        return self[indexPath]
    }

    open subscript(indexPath: IndexPath) -> T {
        get { return _content[indexPath.section][indexPath.item] }
        set {
//            editContent { delegate in
//            _content[indexPath.item] = newValue
//            delegate?.dataSource(self, didUpdateItemsAt: [indexPath])}
        }
    }

    open subscript(section: Int, index: Int) -> T {
        get { return _content[section][index] }
        set {
//            editContent { delegate in
//            _content[index] = newValue
//            let indexPath = IndexPath(item: index, section: 0)
//            delegate?.dataSource(self, didUpdateItemsAt: [indexPath])
//            }
        }
    }

    public var sectionHeaders: [Any]? {
        didSet {
            if let sectionHeaders = sectionHeaders {
                assert(sectionHeaders.count == numberOfSections(), "We should have same count for number of sections")
            }
        }
    }

    open func sectionHeaderItem(at section: Int) -> Any? {
        return sectionHeaders?[section] ?? _content[section]
    }

    open var info: [String: Any] = [:]

}
