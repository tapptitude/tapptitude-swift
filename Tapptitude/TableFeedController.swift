//
//  TableFeedController.swift
//  Tapptitude
//
//  Created by Ion Toderasco on 11/11/2018.
//  Copyright © 2018 Tapptitude. All rights reserved.
//

import Foundation
import UIKit

//public typealias HybridTableFeedController = _TableFeedController<HybridDataSource, HybridCellController>
public typealias TableFeedController = AnyTableFeedController

open class _TableFeedController<D: TTDataSource, C: TTTableCellController>: __TableFeedController where D.ContentType == C.ContentType {
    
    open var dataSource: D? {
        get { return _dataSource as? D }
        set { _dataSource = newValue}
    }
    
    open var cellController: C! {
        get { return _cellController as? C }
        set { _cellController = newValue }
    }
}

open class AnyTableFeedController: __TableFeedController {

    open var dataSource: TTAnyDataSource? {
        get { return _dataSource }
        set { _dataSource = newValue }
    }
    
    open var cellController: TTAnyTableCellController! {
        get { return _cellController }
        set { _cellController = newValue }
    }
}

open class __TableFeedController: UIViewController, TTTableFeedController, TTDataFeedDelegate, TTDataSourceDelegate {
    
    // -- ?
    public struct Options {
        public var loadMoreIndicatorViewColor = UIColor.gray
        public var animateEmptyViewAppearence = true
    }
    
    open var options = Options()
    // -- ??
    
    deinit {
        tableView?.delegate = nil;
        tableView?.dataSource = nil;
        if emptyViewWasInsertedIntoHierarchy {
            emptyView?.removeFromSuperview()
        }
        _dataSource?.delegate = nil
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        updateReloadingIndicatorView()
        updateEmptyViewAppearence(animated: false)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableViewIfMissing()
        updateReloadingIndicatorView()
        updateEmptyViewAppearence(animated: false)

        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    
    /// pass all cellControllers, were cell are created in storyboard
    open func cellsNibsAlreadyRegisteredInStoryboard(for cellControllers: TTAnyTableCellController...) {
        cellControllers.forEach{ registeredCellIdentifiers += $0.allSupportedReuseIdentifiers() }
    }
    
    
    
    internal var emptyViewWasInsertedIntoHierarchy = false
    
    internal var registeredCellIdentifiers: [String] = []
    
    internal weak var previousTableView: UITableView! = nil { // we need this one to track when to clear registered cells
        didSet { registeredCellIdentifiers = [] }
    }
    
    
    //MARK: Table View
    @IBOutlet open weak var tableView: UITableView! {
        willSet {
            tableView?.dataSource = nil
            tableView?.delegate = nil
        }
        
        didSet {
            previousTableView = tableView
            
            if let tableView = self.tableView {
                tableView.delegate = self
                tableView.dataSource = self
                
                loadMoreController?.tableView = tableView

                tableView.estimatedRowHeight = _cellController?.estimatedRowHeight ?? 44
            }
            updateTableViewAnimatedUpdater()
        }
    }
    
    /// proxy for spinnerView in order to have an UIActivityIndicatorView
    @IBOutlet open weak var reloadIndicatorView: UIActivityIndicatorView? {
        didSet { reloadSpinnerView = reloadIndicatorView }
    }
    /// any view that conforms to <TTSpinnerView> protocol { startAnimating | stopAnimating }
    @IBOutlet open weak var reloadSpinnerView: (UIView & TTSpinnerView)?
    
    
    //TODO:- edit empty view. Statefull tableview
    internal lazy var _emptyView: UIView? = {
        let emptyView = UILabel()
        emptyView.backgroundColor = UIColor.clear
        emptyView.text = NSLocalizedString("No content", comment: "No content")
        emptyView.textAlignment = .center
        emptyView.numberOfLines = 0
        emptyView.textColor = UIColor(white: 0.4, alpha: 1.0)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        return emptyView
    }()
    
    /// set from XIB or replace with your view,
    /// set to nil in order to not show emptyView
    @IBOutlet open var emptyView: UIView? {
        set {
            if emptyViewWasInsertedIntoHierarchy {
                _emptyView?.removeFromSuperview()
                emptyViewWasInsertedIntoHierarchy = false
            }
            _emptyView = newValue
        }
        get { return _emptyView }
    }
    
    
    //MARK: DataSource
    public var _dataSource: TTAnyDataSource? {
        willSet {
            if self == (_dataSource?.delegate as? __TableFeedController) {
                _dataSource?.delegate = nil
            }
        }
        
        didSet {
            let feed = _dataSource?.feed
            if feed?.canReload == true && feed?.shouldReload() == true {
                feed?.reload()
            }
            
            _dataSource?.delegate = self
            tableView?.reloadData()
            
            updateReloadingIndicatorView()
            updateEmptyViewAppearence(animated: false)
            updateCanShowLoadMoreView(animated: false)
        }
    }
    
    //MARK: Cell Controller
    public var _cellController: TTAnyTableCellController! {
        willSet {
            _cellController?.parentViewController = nil
        }
        didSet {
            _cellController.parentViewController = self

            tableView?.estimatedRowHeight = _cellController.estimatedRowHeight
        }
    }
    
    func setupTableViewIfMissing() {
        guard self.tableView == nil else {
            return
        }
        
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        view.addSubview(tableView)
        self.tableView = tableView
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        
        setupReloadActivityIndicatorView()
    }
    
    func setupReloadActivityIndicatorView() {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        
        view.addSubview(activityIndicatorView)
        self.reloadIndicatorView = activityIndicatorView
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
    
    open func updateEmptyViewAppearence(animated: Bool) {
        //TODO:- change to statefull tableview
        
        guard let emptyView = self.emptyView else {
            return
        }
        
        let animated = animated && options.animateEmptyViewAppearence
        
        let feedIsLoading = (_dataSource?.feed?.isReloading == true) || (_dataSource?.feed?.isLoadingMore == true)
        let hasContent = _dataSource?.isEmpty == false
        
        if (feedIsLoading || hasContent || _dataSource == nil) {
            if animated {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    emptyView.alpha = 0
                }, completion: { (completed) -> Void in
                    emptyView.isHidden = emptyView.alpha == 0
                })
            } else {
                emptyView.isHidden = true
            }
        } else {
            if let tableView = tableView {
                insertEmptyView(emptyView: emptyView, above: tableView)
            }
            emptyView.isHidden = false
            
            if animated {
                emptyView.alpha = 0.0
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    emptyView.alpha = 1.0
                })
            } else {
                emptyView.alpha = 1.0
            }
        }
    }
    
    internal func insertEmptyView(emptyView: UIView,  above view: UIView) {
        //TODO:- Statefull tableview
        
        if emptyView.superview == nil && view.superview != nil {
            self.emptyViewWasInsertedIntoHierarchy = true
            view.superview?.insertSubview(emptyView, aboveSubview: view)
            
            // keep same size / position as view
            if emptyView.constraints.isEmpty {
                [ NSLayoutConstraint(item: emptyView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0),
                  NSLayoutConstraint(item: emptyView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0.0),
                  NSLayoutConstraint(item: emptyView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                  NSLayoutConstraint(item: emptyView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
                    ].forEach({ $0.isActive = true })
            }
        }
    }
    
    open func updateReloadingIndicatorView() {
        let spinner = reloadSpinnerView
        
        guard let dataSource = self._dataSource else {
            spinner?.stopAnimating()
            return
        }
        
        guard dataSource.feed?.isReloading == true else {
            spinner?.stopAnimating()
            return
        }
        if !(hideReloadViewIfHasContent && !dataSource.isEmpty) {
            if refreshControl == nil || (refreshControl?.isRefreshing == false) {
                spinner?.startAnimating()
            }
        }
    }
    
    open var hideReloadViewIfHasContent: Bool = true
    
    //MARK: Load More
    open var loadMoreController: TableLoadMoreController? = TableLoadMoreController()
    
    //MARK: Pull to Refresh -
    @IBOutlet open  weak var refreshControl: UIRefreshControl?
    
    open func addPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = tableView.backgroundColor
        refreshControl.addTarget(self, action: #selector(pullToRefreshAction(_:)), for: .valueChanged)
        self.refreshControl = refreshControl
        tableView.addSubview(refreshControl)
    }
    
    @objc open func pullToRefreshAction(_ sender: AnyObject!) {
        _dataSource!.feed!.reload()
    }
    
    
    //MARK:- Data Feed
    
    /// last error, if any, that we got from feed reload/loadMore operation
    var lastFeedError: Error?
    
    public func dataFeed(_ dataFeed: TTDataFeed?, didLoadResult result: Result<[Any]>, forState: FeedState.Load) {
        switch forState {
        case .reloading:
            refreshControl?.endRefreshing()
        case .loadingMore:
            break
        }
        
        self.lastFeedError = result.error
        if let error = lastFeedError {
            checkAndShow(error: error)
        }
    }
    
    public func dataFeed(_ dataFeed: TTDataFeed?, stateChangedFrom fromState: FeedState, toState: FeedState) {
        //TODO:- Check statefull tableview
        switch (fromState, toState) {
        case (_, .reloading), (.reloading, _):
            updateReloadingIndicatorView()
        default: break
        }
        
        checkIfShouldLoadMoreContent()
        updateCanShowLoadMoreView(animated: true)
        updateEmptyViewAppearence(animated: true)
    }
    
    
    func updateCanShowLoadMoreView(animated: Bool) {
        loadMoreController?.updateCanShowLoadMoreView(for: _dataSource?.feed, animated: animated)
    }
    
    func checkIfShouldLoadMoreContent() {
        if lastFeedError == nil {
            loadMoreController?.checkIfShouldLoadMoreContent(for: _dataSource?.feed)
        }
    }
    
    
    open var animatedUpdates = false {
        didSet { updateTableViewAnimatedUpdater() }
    }
    
    /// any changes in datasource will be passed to collectionView
    public var propagateDataSourceChangesIntoCollectionView = true {
        didSet { updateTableViewAnimatedUpdater() }
    }
    
    fileprivate var animatedUpdater: TTTableViewUpdater?
    
    func updateTableViewAnimatedUpdater() {
        guard let _ = self.tableView else {
            animatedUpdater = nil
            return
        }
        
        switch (propagateDataSourceChangesIntoCollectionView, animatedUpdates) {
        case (false, _):
            animatedUpdater = nil
        case (true, _):
            animatedUpdater = TableViewUpdater(animatesUpdates: animatedUpdates)
        }
    }
    
    @available(iOS 11.0, *)
    open func perfomBatchUpdates(_ updates: @escaping (() -> Void), animationCompletion: (()->Void)?) {
        let animatedUpdater = BatchCollectionViewUpdater(animatesUpdates: animatedUpdates)
        self.animatedUpdater = animatedUpdater
        tableView.performBatchUpdates({
            updates()
            animatedUpdater.batchOperation?.forEach{ $0() }
        }) { (completed) in
            animationCompletion?()
        }
        updateTableViewAnimatedUpdater()
    }
    
    
    public func dataSourceWillChangeContent(_ dataSource: TTAnyDataSource) {
        animatedUpdater?.tableViewWillChangeContent(tableView!)
    }
    
    public func dataSourceDidChangeContent(_ dataSource: TTAnyDataSource) {
        animatedUpdater?.tableViewDidChangeContent(tableView!, animationCompletion: nil)
        
        if dataSource.feed == nil || dataSource.feed!.isReloading == false { // check for the empty view
            updateEmptyViewAppearence(animated: true)
        }
    }
    
    public func dataSource(_ dataSource: TTAnyDataSource, didUpdateItemsAt indexPaths: [IndexPath]) {
        animatedUpdater?.tableView(tableView!, didUpdateItemsAt: indexPaths)
    }
    
    public func dataSource(_ dataSource: TTAnyDataSource, didDeleteItemsAt indexPaths: [IndexPath]) {
        animatedUpdater?.tableView(tableView!, didDeleteItemsAt: indexPaths)
    }
    
    public func dataSource(_ dataSource: TTAnyDataSource, didInsertItemsAt indexPaths: [IndexPath]) {
        animatedUpdater?.tableView(tableView!, didInsertItemsAt: indexPaths)
    }
    
    public func dataSource(_ dataSource: TTAnyDataSource, didMoveItemsFrom fromIndexPaths: [IndexPath], to toIndexPaths: [IndexPath]) {
        animatedUpdater?.tableView(tableView!, didMoveItemsFrom: fromIndexPaths, to: toIndexPaths)
    }
    
    public func dataSource(_ dataSource: TTAnyDataSource, didInsertSections addedSections: IndexSet) {
        animatedUpdater?.tableView(tableView!, didInsertSections: addedSections)
    }
    
    public func dataSource(_ dataSource: TTAnyDataSource, didDeleteSections deletedSections: IndexSet) {
        animatedUpdater?.tableView(tableView!, didDeleteSections: deletedSections)
    }
    
    public func dataSource(_ dataSource: TTAnyDataSource, didUpdateSections updatedSections: IndexSet) {
        animatedUpdater?.tableView(tableView!, didUpdateSections: updatedSections)
    }
    
    /// how load more content is [appended / inserted ] in datasource
    public var dataSourceLoadMoreType: TTDataSourceLoadMoreType = .appendAtEnd {
        didSet {
            switch dataSourceLoadMoreType {
            case .appendAtEnd: // default behaviour
                break
            case .insertAtBeginning:
                let loadMoreController = TableLoadMoreController()
                loadMoreController.tableView = tableView!
                loadMoreController.loadMorePosition = .top
                self.loadMoreController = loadMoreController
            }
        }
    }
    
    
    //MARK:- TableView Delegate
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _dataSource!.numberOfItems(inSection: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = _dataSource!.item(at: indexPath)
        let reuseIdentifier = _cellController.reuseIdentifier(for: content)
        
        if registeredCellIdentifiers.contains(reuseIdentifier) == false {
            if let nib = _cellController.nibToInstantiateCell(for: content) {
                tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
            } else {
                let cellClass: AnyClass? = _cellController.classToInstantiateCell(for: content)
                tableView.register(cellClass, forCellReuseIdentifier: reuseIdentifier)
            }
            registeredCellIdentifiers.append(reuseIdentifier)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        assert(_cellController.acceptsContent(content), "Can't produce cell for content \(content)")
        assert(cell.reuseIdentifier == reuseIdentifier , "Cell returned from cell controller \(String(describing: _cellController)) had reuseIdenfier \(cell.reuseIdentifier!), which must be equal to the cell controller's reuseIdentifierForContent, which returned \(reuseIdentifier)")
        
        // pass parentViewController
        cell.parentViewController = _cellController.parentViewController
        
        _cellController.configureCell(cell, for: content, at: indexPath)
        
        return cell
    }
    
    //TODO: loadmore
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.parentViewController = nil
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.parentViewController = _cellController.parentViewController
        
        checkIfShouldLoadMoreContent()
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let content = _dataSource!.item(at: indexPath)
        return _cellController.cellHeight(for: content, in: tableView)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = _dataSource!.item(at: indexPath)
        _cellController.didSelectContent(content, at: indexPath, in: tableView)
    }
}
