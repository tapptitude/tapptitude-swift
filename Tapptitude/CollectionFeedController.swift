//
//  CollectionFeedController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

open class CollectionFeedController: UIViewController, TTCollectionFeedController, TTDataFeedDelegate, TTDataSourceDelegate {
    
    public struct Options {
        public var loadMoreIndicatorViewColor = UIColor.gray
    }
    
    open var options = Options()
    
    deinit {
        collectionView?.delegate = nil;
        collectionView?.dataSource = nil;
        if emptyViewWasInsertedIntoHierarchy {
            emptyView?.removeFromSuperview()
        }
        dataSource?.delegate = nil
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        updateReloadingIndicatorView()
        updateEmptyViewAppearence(animated: false)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        updateReloadingIndicatorView()
        updateEmptyViewAppearence(animated: false)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        forceTouchPreview?.setupForceTouchPreview()
    }
    
    
    /// pass all cellControllers, were cell are created in storyboard
    open func cellsNibsAlreadyRegisteredInStoryboard(for cellControllers: TTAnyCollectionCellController...) {
        cellControllers.forEach{ registeredCellIdentifiers += $0.allSupportedReuseIdentifiers() }
    }
    
    open var useAutoLayoutEstimatedSize: Bool = false {
        didSet {
            assert(collectionView != nil, "CollectionView should be loaded")
            
            if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                if !useAutoLayoutEstimatedSize {
                    layout.estimatedItemSize = CGSize.zero
                } else if #available(iOS 10.0, *) {
                    layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
                } else {
                    var size = self.cellController.cellSize
                    size.width = size.width < 0 ? collectionView.bounds.size.width : size.width
                    size.height = size.height < 0 ? collectionView.bounds.size.height: size.height
                    layout.estimatedItemSize = size
                }
            }
        }
    }
    
    internal var registeredCellIdentifiers : [String] = []
    internal var isScrollDirectionConfigured : Bool = false
    internal weak var previousCollectionView : UICollectionView! = nil { // we need this one to track when to clear registered cells
        didSet { registeredCellIdentifiers = [] }
    }
    
    @IBOutlet open weak var collectionView: UICollectionView! {
        willSet {
            collectionView?.dataSource = nil
            collectionView?.delegate = nil
        }
        
        didSet {
            previousCollectionView = collectionView
            
            if let collectionView = self.collectionView {
                collectionView.delegate = self
                collectionView.dataSource = self
                
                if !self.isScrollDirectionConfigured {
                    // fetch scrollDirection value from collectionView layout
                    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                        self.scrollDirection = layout.scrollDirection
                    }
                }
                
                loadMoreController?.collectionView = collectionView
                updateCollectionViewScrollDirection()
                updateCollectionViewLayoutAttributes()
                updatePrefetcherController()
            }
            updateCollectionViewAnimatedUpdater()
        }
    }
    
    /// proxy for spinnerView in order to have an UIActivityIndicatorView
    @IBOutlet open weak var reloadIndicatorView: UIActivityIndicatorView? {
        didSet { reloadSpinnerView = reloadIndicatorView }
    }
    /// any view that conforms to <TTSpinnerView> protocol { startAnimating | stopAnimating }
    @IBOutlet open weak var reloadSpinnerView: UIView?
    
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
       
    
    open var dataSource: TTDataSource? {
        willSet {
            if self == (dataSource?.delegate as? CollectionFeedController) {
                dataSource?.delegate = nil
            }
        }
        
        didSet {
            let feed = dataSource?.feed
            if feed?.canReload == true && feed?.shouldReload() == true {
                feed?.reload()
            }
            
            dataSource?.delegate = self
            collectionView?.reloadData()
            
            updateReloadingIndicatorView()
            updateEmptyViewAppearence(animated: false)
            updateCanShowLoadMoreViewAnimated(false)
        }
    }
    
    var prefetchController: CollectionCellPrefetcherDelegate?
    
    open var cellController: TTAnyCollectionCellController! {
        willSet {
            cellController?.parentViewController = nil
        }
        didSet {
            cellController.parentViewController = self
            updateCollectionViewLayoutAttributes()
            updatePrefetcherController()
        }
    }
    
    open var headerController: TTAnyCollectionHeaderController? {
        willSet { headerController?.parentViewController = nil }
        didSet { headerController?.parentViewController = self }
    }
    
    open var headerIsSticky = false {
        didSet {
            if #available(iOS 9.0, *) {
                (self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout).sectionHeadersPinToVisibleBounds = headerIsSticky
            }
        }
    }
    
    open var scrollDirection: UICollectionViewScrollDirection = .vertical {
        didSet {
            isScrollDirectionConfigured = true
            updateCollectionViewScrollDirection()
        }
    }
    internal func updateCollectionViewScrollDirection() {
        let verticalScroll = (self.scrollDirection == .vertical)
        let horizontalScroll = (self.scrollDirection == .horizontal)
        
        collectionView?.scrollsToTop = verticalScroll
        collectionView?.alwaysBounceHorizontal = horizontalScroll
        collectionView?.alwaysBounceVertical = verticalScroll
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = self.scrollDirection
        }
        
        switch scrollDirection {
        case .horizontal: loadMoreController?.loadMorePosition = .right
        case .vertical: loadMoreController?.loadMorePosition = .bottom
        }
        
    }
    
    internal func updateCollectionViewLayoutAttributes() {
        if cellController == nil || collectionView == nil {
            return
        }
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = cellController.sectionInset
            layout.minimumLineSpacing = cellController.minimumLineSpacing
            layout.minimumInteritemSpacing = cellController.minimumInteritemSpacing
            if cellController.cellSize.width > 0.0 && cellController.cellSize.height > 0.0 {
                layout.itemSize = cellController.cellSize
            }
        }
    }
    
    
    // UI appearence
    internal var emptyViewWasInsertedIntoHierarchy = false
    open func updateEmptyViewAppearence(animated: Bool) {
        guard let emptyView = self.emptyView else {
            return
        }
        
        let feedIsLoading = (dataSource?.feed?.isReloading == true) || (dataSource?.feed?.isLoadingMore == true)
        let hasContent = dataSource?.isEmpty == false
        
        if (feedIsLoading || hasContent || dataSource == nil) {
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
            if let collectionView = collectionView {
                insertEmptyView(emptyView: emptyView, above: collectionView)
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
        let spinner = reloadSpinnerView as? TTSpinnerView
        
        guard let dataSource = self.dataSource else {
            spinner?.stopAnimating()
            return
        }
        
        if dataSource.feed?.isReloading == true {
            if hideReloadViewIfHasContent && !dataSource.isEmpty {
                
            } else {
                if refreshControl == nil || (refreshControl?.isRefreshing == false) {
                    spinner?.startAnimating()
                }
            }
        } else {
            spinner?.stopAnimating()
        }
    }
    open var hideReloadViewIfHasContent: Bool = true
    
    //MARK: Load More -
    open var loadMoreController: TTLoadMoreController? = LoadMoreFooterController()// LoadMoreController() //
    
    //MARK: ForceTouch Preview -
    open var forceTouchPreview: ForceTouchPreview?
    open var forceTouchPreviewEnabled: Bool = false {
        didSet {
            self.forceTouchPreview = forceTouchPreviewEnabled ? ForceTouchPreview(collectionController: self) : nil
        }
    }
    
    //MARK: Pull to Refresh -
    @IBOutlet open  weak var refreshControl: UIRefreshControl?
    @objc open func pullToRefreshAction(_ sender: AnyObject!) {
        dataSource!.feed!.reload()
    }
    open func addPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = collectionView.backgroundColor
        refreshControl.addTarget(self, action: #selector(CollectionFeedController.pullToRefreshAction(_:)), for: .valueChanged)
        self.refreshControl = refreshControl
        collectionView.addSubview(refreshControl)
    }
//}
//
//
////MARK: Data Feed -
//extension CollectionFeedController : TTDataFeedDelegate {
    
    /// last error, if any, that we got from feed reload/loadMore operation
    var lastFeedError: Error?
    
    open func dataFeed(_ dataFeed: TTDataFeed?, didLoadResult result: Result<[Any]>, forState: FeedState.Load) {
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
    
    open func dataFeed(_ dataFeed: TTDataFeed?, stateChangedFrom fromState: FeedState, toState: FeedState) {
        switch (fromState, toState) {
        case (_, .reloading), (.reloading, _):
            updateReloadingIndicatorView()
        default: break
        }
        
        checkIfShouldLoadMoreContent()
        updateCanShowLoadMoreViewAnimated(true)
        updateEmptyViewAppearence(animated: true)
    }
    
    func checkIfShouldLoadMoreContent() {
        if lastFeedError == nil {
            loadMoreController?.checkIfShouldLoadMoreContent(for: dataSource?.feed)
        }
    }
    func updateCanShowLoadMoreViewAnimated(_ animated: Bool) {
        loadMoreController?.updateCanShowLoadMoreView(for: dataSource?.feed, animated: animated)
    }
//}
//
//
//
// MARK: Incremental Changes on Data source
//extension CollectionFeedController : TTDataSourceDelegate {
    open var animatedUpdates = false {
        didSet { updateCollectionViewAnimatedUpdater() }
    }
    /// any changes in datasource will be passed to collectionView
    public var propagateDataSourceChangesIntoCollectionView = true {
        didSet { updateCollectionViewAnimatedUpdater() }
    }
    fileprivate var animatedUpdater: TTCollectionViewUpdater?
    
    func updateCollectionViewAnimatedUpdater() {
        guard let _ = self.collectionView else {
            animatedUpdater = nil
            return
        }
        
        switch (propagateDataSourceChangesIntoCollectionView, animatedUpdates) {
        case (false, _):
            animatedUpdater = nil
        case (true, _):
            animatedUpdater = CollectionViewUpdater(animatesUpdates: animatedUpdates)
        }
    }
    
    open func perfomBatchUpdates(_ updates: @escaping (() -> Void), animationCompletion:(()->Void)?) {
        let animatedUpdater = BatchCollectionViewUpdater(animatesUpdates: animatedUpdates)
        self.animatedUpdater = animatedUpdater
        collectionView.performBatchUpdates({ 
            updates()
            animatedUpdater.batchOperation?.forEach{ $0() }
        }) { (completed) in
            animationCompletion?()
        }
        updateCollectionViewAnimatedUpdater()
    }
    
    open func dataSourceWillChangeContent(_ dataSource: TTDataSource) {
        animatedUpdater?.collectionViewWillChangeContent(collectionView!)
    }
    
    open func dataSourceDidChangeContent(_ dataSource: TTDataSource) {
        animatedUpdater?.collectionViewDidChangeContent(collectionView!, animationCompletion: nil)
        
        if dataSource.feed == nil || dataSource.feed!.isReloading == false { // check for the empty view
            updateEmptyViewAppearence(animated: true)
        }
    }
    
    open func dataSource(_ dataSource: TTDataSource, didUpdateItemsAt indexPaths: [IndexPath]) {
        animatedUpdater?.collectionView(collectionView!, didUpdateItemsAt: indexPaths)
    }
    
    open func dataSource(_ dataSource: TTDataSource, didDeleteItemsAt indexPaths: [IndexPath]) {
        animatedUpdater?.collectionView(collectionView!, didDeleteItemsAt: indexPaths)
    }
    
    open func dataSource(_ dataSource: TTDataSource, didInsertItemsAt indexPaths: [IndexPath]) {
        animatedUpdater?.collectionView(collectionView!, didInsertItemsAt: indexPaths)
    }
    
    open func dataSource(_ dataSource: TTDataSource, didMoveItemsFrom fromIndexPaths: [IndexPath], to toIndexPaths: [IndexPath]) {
        animatedUpdater?.collectionView(collectionView!, didMoveItemsFrom: fromIndexPaths, to: toIndexPaths)
    }
    
    open func dataSource(_ dataSource: TTDataSource, didInsertSections addedSections: IndexSet) {
        animatedUpdater?.collectionView(collectionView!, didInsertSections: addedSections)
    }
    open func dataSource(_ dataSource: TTDataSource, didDeleteSections deletedSections: IndexSet) {
        animatedUpdater?.collectionView(collectionView!, didDeleteSections: deletedSections)
    }
    open func dataSource(_ dataSource: TTDataSource, didUpdateSections updatedSections: IndexSet) {
        animatedUpdater?.collectionView(collectionView!, didUpdateSections: updatedSections)
    }
//}
//
// MARK: Data Source -
//extension CollectionFeedController : UICollectionViewDataSource {
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        assert(cellController != nil, "cellController is nil, please set self.cellController = ...(YourCellController)")
        guard let dataSource = self.dataSource else {
            return 0
        }
        
        // register only once per collectionView
        if (previousCollectionView != collectionView) {
            previousCollectionView = collectionView
            self.registeredCellIdentifiers = []
        }
        
        return dataSource.numberOfSections()
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource!.numberOfItems(inSection: section)
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let content = dataSource![indexPath]
        let reuseIdentifier = cellController.reuseIdentifier(for: content)
        
        if registeredCellIdentifiers.contains(reuseIdentifier) == false {
            if let nib = cellController.nibToInstantiateCell(for: content) {
                collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
            } else {
                let cellClass: AnyClass? = cellController.classToInstantiateCell(for: content)
                collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
            }
            
            registeredCellIdentifiers.append(reuseIdentifier)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        assert(cellController.acceptsContent(content), "Can't produce cell for content \(content)")
        assert(cell.reuseIdentifier == reuseIdentifier , "Cell returned from cell controller \(cellController) had reuseIdenfier \(cell.reuseIdentifier!), which must be equal to the cell controller's reuseIdentifierForContent, which returned \(reuseIdentifier)")
        
        // pass parentViewController
        cell.parentViewController = cellController.parentViewController;
        
        cellController.configureCell(cell, for: content, at: indexPath)
        
        return cell;
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let dataSource = self.dataSource else {
            return UICollectionReusableView()
        }
        
        if kind == UICollectionElementKindSectionFooter {
            return loadMoreController!.loadMoreView(in: collectionView, at: indexPath)!
        }
        
        // header view
        let showHeader = kind == UICollectionElementKindSectionHeader
        if showHeader, let headerController = headerController  {
            let content = dataSource.sectionHeaderItem(at: indexPath.section)!
            let reuseIdentifier = headerController.reuseIdentifier(for: content)
            
            if registeredCellIdentifiers.contains(kind + reuseIdentifier) == false {
                if let nib = headerController.nibToInstantiate(for: content) {
                    collectionView.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
                } else {
                    let headerClass: AnyClass? = headerController.classToInstantiate(for: content)
                    collectionView.register(headerClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
                }
                
                registeredCellIdentifiers.append(kind + reuseIdentifier)
            }
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath)
            headerView.parentViewController = self
            headerController.configureHeader(headerView, for: content, at: indexPath)
            
            return headerView
        }
        
        assert(true, "Could not show load more view -> there is some bug in dataSource implementation as we should not get here")
        
        return UICollectionReusableView() // just to ingore compilation error
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.parentViewController = nil
        loadMoreController?.updateLoadMoreViewPosition(in: collectionView)
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.parentViewController = cellController.parentViewController
        
        checkIfShouldLoadMoreContent()
        loadMoreController?.updateLoadMoreViewPosition(in: collectionView)
    }
    
    open func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        self.loadMoreController?.updateLoadMoreViewPosition(in: collectionView)
        return proposedContentOffset
    }
//}
//
//
//
// MARK: Did Select -
//extension CollectionFeedController {
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let content = dataSource![indexPath]
        cellController.didSelectContent(content, at: indexPath, in: collectionView)
    }


// MARK: Layout Size -
//extension CollectionFeedController {
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let content = dataSource![indexPath]
        let size = cellController.cellSize(for: content, in: collectionView)
        let boundsSize = collectionView.bounds.size
        return CGSize(width: size.width < 0.0 ? boundsSize.width : size.width, height: size.height < 0.0 ? boundsSize.height : size.height)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var insets = UIEdgeInsets.zero
        if let dataSource = dataSource, dataSource.numberOfItems(inSection: section) > 0 {
            let first = dataSource[section, 0]
            insets = cellController.sectionInset(for: first, in: collectionView)
//            let last = dataSource[section, dataSource.numberOfItems(inSection: section) - 1]
//            insets.bottom = cellController.sectionInset(for: last, in: collectionView).bottom
        }
        
        if let loadMore = loadMoreController {
            insets = loadMore.adjustSectionInsetToShowLoadMoreView(sectionInset: insets, collectionView: collectionView, section: section)
        }
        
        return insets
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let dataSource = dataSource, dataSource.numberOfItems(inSection: section) > 0 {
            let content = dataSource[section, 0]
            return cellController.minimumInteritemSpacing(for: content, in: collectionView)
        } else {
            return 0.0
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let dataSource = dataSource, dataSource.numberOfItems(inSection: section) > 0 {
            let content = dataSource[section, 0]
            return cellController.minimumLineSpacing(for: content, in: collectionView)
        } else {
            return 0.0
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return loadMoreController?.sizeForLoadMoreViewInSection(section, collectionView: collectionView) ?? CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection  section: Int) -> CGSize {
        if let dataSource = dataSource, dataSource.numberOfItems(inSection: section) > 0,
            let headerController = headerController,
            let item = dataSource.sectionHeaderItem(at: section), 
            headerController.acceptsContent(item) {
            return headerController.headerSize(for: item, in: collectionView)
        } else {
            return CGSize.zero
        }
    }
    
    open var isReversed: Bool = false {
        didSet {
            if isReversed {
                self.collectionView.collectionViewLayout = ChatFlowLayout()
            }
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        forceTouchPreview?.setupForceTouchPreview()
    }
}
