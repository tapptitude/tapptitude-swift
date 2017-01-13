//
//  CollectionFeedController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

open class CollectionFeedController: UIViewController, TTCollectionFeedController, TTDataFeedDelegate, TTDataSourceDelegate, UIViewControllerPreviewingDelegate {
    
    public struct Options {
        public var emptyMessage = NSLocalizedString("No content", comment: "No content")
        public var emptyMessageFont: UIFont?
        public var loadMoreIndicatorViewColor = UIColor.gray
    }
    
    open var options = Options()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        collectionView?.delegate = nil;
        collectionView?.dataSource = nil;
        displayedEmptyView?.removeFromSuperview()
        dataSource?.delegate = nil
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        updateReloadingIndicatorView()
        updateEmptyViewAppearenceAnimated(false)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if forceTouchPreviewEnabled {
            registerForceTouchPreview()
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        updateReloadingIndicatorView()
        updateEmptyViewAppearenceAnimated(false)
    }
    
    internal var registeredCellIdentifiers : [String]?
    internal var isScrollDirectionConfigured : Bool = false
    internal weak var previousCollectionView : UICollectionView! = nil
    
    @IBOutlet open weak var collectionView: UICollectionView? {
        willSet {
            collectionView?.dataSource = nil
            collectionView?.delegate = nil
        }
        
        didSet {
            registeredCellIdentifiers = nil
            
            if let collectionView = self.collectionView {
                collectionView.delegate = self
                collectionView.dataSource = self
                
                let nib = UINib(nibName: loadMoreViewXIBName, bundle: Bundle(for: CollectionFeedController.self))
                collectionView.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: loadMoreViewXIBName)
                
                if !self.isScrollDirectionConfigured {
                    // fetch scrollDirection value from collectionView layout
                    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                        self.scrollDirection = layout.scrollDirection
                    }
                }
                updateCollectionViewScrollDirection()
                updateCollectionViewLayoutAttributes()
            }
        }
    }
    
    @IBOutlet open weak var reloadIndicatorView: UIActivityIndicatorView?
    internal var _emptyView: UIView?
    @IBOutlet open var emptyView: UIView? { //set from XIB or overwrite
        set {
            _emptyView = newValue
            _emptyView?.removeFromSuperview()
        }
        get {
            if collectionView == nil || dataSource == nil {
                return nil
            }
            
            if _emptyView != nil {
                return _emptyView
            }
            
            let noContent = UILabel()
            noContent.backgroundColor = UIColor.clear
            noContent.text = options.emptyMessage
            noContent.frame = collectionView!.frame.integral
            noContent.textAlignment = .center
            noContent.numberOfLines = 0
            noContent.textColor = UIColor(white: 0.4, alpha: 1.0)
            noContent.autoresizingMask = collectionView!.autoresizingMask
            if let font = options.emptyMessageFont {
                noContent.font = font
            }
            
            return noContent;
        }
    }
    
    open var dataSource: TTDataSource? {
        willSet {
            displayedEmptyView?.removeFromSuperview()
            displayedEmptyView = nil
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
            reloadDataOnCollectionView()
            
            updateReloadingIndicatorView()
            updateEmptyViewAppearenceAnimated(false)
            updateCanShowLoadMoreViewAnimated(false)
        }
    }
    
    open var cellController: TTCollectionCellControllerProtocol! {
        willSet {
            cellController?.parentViewController = nil
        }
        didSet {
            cellController.parentViewController = self
            updateCollectionViewLayoutAttributes()
        }
    }
    
    open var headerController: TTCollectionHeaderControllerProtocol? {
        willSet {
            headerController?.parentViewController = nil
        }
        didSet {
            headerController?.parentViewController = self
        }
    }
    
    open var headerIsSticky = false {
        didSet {
            if #available(iOS 9.0, *) {
                (self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).sectionHeadersPinToVisibleBounds = headerIsSticky
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
    
    
    internal var displayedEmptyView : UIView?
    // UI appearence
    open func updateEmptyViewAppearenceAnimated(_ animated: Bool) {
        let feedIsLoading = (dataSource?.feed?.isReloading == true) || (dataSource?.feed?.isLoadingMore == true)
        let hasContent = (dataSource != nil) && dataSource?.isEmpty == false
        
        if (feedIsLoading || hasContent) && displayedEmptyView != nil {
            if animated {
                let emptyView = displayedEmptyView
                displayedEmptyView = nil
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    emptyView?.alpha = 0
                    }, completion: { (_) -> Void in
                        if emptyView != self.emptyView {
                            emptyView?.removeFromSuperview()
                        }
                })
            } else {
                displayedEmptyView?.removeFromSuperview()
                displayedEmptyView = nil
            }
        } else if !hasContent && !feedIsLoading {
            if displayedEmptyView == nil {
                if let newEmptyView = emptyView { // get new empty view
                    newEmptyView.alpha = 1.0
                    collectionView?.superview?.insertSubview(newEmptyView, aboveSubview: collectionView!)
                    displayedEmptyView = newEmptyView
                }
            }
            
            if animated {
                displayedEmptyView?.alpha = 0.0
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.displayedEmptyView?.alpha = 1.0
                })
            }
        }
    }
    
    open func updateReloadingIndicatorView() {
        guard let dataSource = self.dataSource else {
            reloadIndicatorView?.stopAnimating()
            return
        }
        
        if dataSource.feed?.isReloading == true {
            if hideReloadViewIfHasContent && !dataSource.isEmpty {
                
            } else {
                if refreshControl == nil || (refreshControl?.isRefreshing == false) {
                    reloadIndicatorView?.startAnimating()
                }
            }
        } else {
            reloadIndicatorView?.stopAnimating()
        }
    }
    open var hideReloadViewIfHasContent: Bool = true
    
    
    
    open func scrollToElement<T>(ofFirst filter: (_ item: T) -> Bool, animated: Bool) {
        guard let collectionView = self.collectionView, let dataSource = self.dataSource else {
            return
        }
        
        if let indexPath = dataSource.indexPath(ofFirst: filter) {
            let layout = collectionView.collectionViewLayout
            var attribute = layout.layoutAttributesForItem(at: indexPath)
            if (attribute?.frame.size.width ?? 0.0) < 1.0 {
                layout.prepare()
                attribute = layout.layoutAttributesForItem(at: indexPath)
                collectionView.contentSize = layout.collectionViewContentSize
            }
            
            if attribute != nil {
                collectionView.scrollRectToVisible(attribute!.frame, animated: animated)
            }
        }
    }
    
    //MARK: Load More -
    open var supportsLoadMore: Bool = true
    open var autoLoadMoreContent: Bool = true
    open var numberOfPagesToPreload: Int = 2 // load more content when last 2 pages are visible
    open var canShowLoadMoreView : Bool = false
    open func shouldShowLoadMore(section: Int) -> Bool { // default - YES only for last section
        return (dataSource != nil && (section == dataSource!.numberOfSections() - 1))
    }
    
    open var loadMoreViewXIBName: String! = "LoadMoreView" // Expected same methods as in LoadMoreView
    internal func updateCanShowLoadMoreViewAnimated(_ animated:Bool) {
        let feed = self.dataSource?.feed
        let showLoadMore = supportsLoadMore && (feed?.canLoadMore == true || feed?.isLoadingMore == true)
        
        if feed != nil {
            print("showLoadMore = \(showLoadMore)")
        }
        if canShowLoadMoreView != showLoadMore {
            if animated == true, let collectionView = collectionView, collectionView.indexPathsForVisibleItems.count > 0 {
                collectionView.performBatchUpdates({ () -> Void in
                    self.canShowLoadMoreView = showLoadMore
                    self.collectionView?.collectionViewLayout.invalidateLayout()
                    }, completion: nil)
            } else {
                canShowLoadMoreView = showLoadMore
                collectionView?.collectionViewLayout.invalidateLayout()
            }
            print("canShowLoadMoreView = \(canShowLoadMoreView)")
        }
    }
    
    open func checkIfShouldLoadMoreContent() {
        guard let collectionView = collectionView, let feed = dataSource?.feed else {
            return
        }
        
        if autoLoadMoreContent && supportsLoadMore && feed.canLoadMore == true {
            if let indexPath = collectionView.indexPathsForVisibleItems.last {
                self.checkIfShouldLoadMoreContentForIndexPath(indexPath)
            } else if dataSource?.isEmpty == true {
                feed.loadMore()
            }
        }
    }
    
    internal func checkIfShouldLoadMoreContentForIndexPath(_ indexPath: IndexPath?) {  //Future - indexPath used for identifying section
        guard let feed = self.dataSource?.feed, let indexPath = indexPath, let collectionView = collectionView else {
            return
        }
        
        guard supportsLoadMore && feed.canLoadMore == true else {
            return
        }
        
        if shouldShowLoadMore(section: indexPath.section) {
            var preloadMoreContent = false
            let bounds = collectionView.bounds
            let contentSize = collectionView.contentSize
            let numberOfPagesToPreload = CGFloat(self.numberOfPagesToPreload)
            
            if scrollDirection == .vertical {
                preloadMoreContent = (contentSize.height - bounds.maxY) < (numberOfPagesToPreload * bounds.size.height)
            } else  {
                preloadMoreContent = (contentSize.width - bounds.maxX) < (numberOfPagesToPreload * bounds.size.width)
            }
            
            if preloadMoreContent {
                feed.loadMore()
            }
        }
    }
    
    
    //MARK: ForceTouch Preview -
    internal weak var forceTouchPreviewContext: UIViewControllerPreviewing?
    open var forceTouchPreviewEnabled: Bool = false {
        didSet {
            if !isViewLoaded {
                return
            }
            
            if forceTouchPreviewEnabled {
                registerForceTouchPreview()
            } else {
                unregisterForceTouchPreview()
            }
        }
    }
    
    //MARK: Pull to Refresh -
    @IBOutlet open  weak var refreshControl: UIRefreshControl?
    open func pullToRefreshAction(_ sender: AnyObject!) {
        dataSource?.feed?.reload()
    }
    open func addPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = collectionView?.backgroundColor
        refreshControl.addTarget(self, action: #selector(CollectionFeedController.pullToRefreshAction(_:)), for: .valueChanged)
        self.refreshControl = refreshControl
        collectionView?.addSubview(refreshControl)
    }
    
    internal func reloadDataOnCollectionView() {
        // apple bug, after reload, collectionview calls unhighlight on cells that where removed from superview.
        let method = "_" + "unhighlightAllItems"
        let selector = Selector(method)
        if collectionView?.responds(to: selector) == true {
            let _ = collectionView?.perform(selector)
        }
        collectionView?.reloadData()
    }
    
    
    open var animatedUpdates = false
    fileprivate var animatedUpdater: CollectionViewAnimatedUpdater?
//}
//
//
////MARK: Data Feed -
//extension CollectionFeedController : TTDataFeedDelegate {
    open func dataFeed(_ dataFeed: TTDataFeed?, failedWithError error: Error) {
        refreshControl?.endRefreshing()
    }
    
    open func dataFeed(_ dataFeed: TTDataFeed?, didReloadContent content: [Any]?) {
        refreshControl?.endRefreshing()
    }
    
    open func dataFeed(_ dataFeed: TTDataFeed?, didLoadMoreContent content: [Any]?) {
        
    }
    
    open func dataFeed(_ dataFeed: TTDataFeed?, isReloading: Bool) {
        checkIfShouldLoadMoreContent()
        updateReloadingIndicatorView()
        updateCanShowLoadMoreViewAnimated(true)
        updateEmptyViewAppearenceAnimated(true)
    }
    
    open func dataFeed(_ dataFeed: TTDataFeed?, isLoadingMore: Bool) {
        checkIfShouldLoadMoreContent()
        updateCanShowLoadMoreViewAnimated(true)
        updateEmptyViewAppearenceAnimated(true)
    }
//}
//
//
//
// MARK: Incremental Changes on Data source
//extension CollectionFeedController : TTDataSourceDelegate {
    open func dataSourceWillChangeContent(_ dataSource: TTDataSource) {
        if let collectionView = collectionView {
            animatedUpdater = animatedUpdates ? CollectionViewAnimatedUpdater() : nil
            animatedUpdater?.collectionViewWillChangeContent(collectionView)
        } else {
            animatedUpdater = nil
        }
    }
    
    open func dataSourceDidChangeContent(_ dataSource: TTDataSource, animationCompletion: (() -> Void)?) {
        if animatedUpdater == nil {
            reloadDataOnCollectionView()
        } else {
            animatedUpdater?.collectionViewDidChangeContent(collectionView!, animationCompletion: animationCompletion)
        }
        
        if dataSource.feed == nil || dataSource.feed!.isReloading == false { // check for the empty view
            updateEmptyViewAppearenceAnimated(true)
        }
        
        animatedUpdater = nil
    }

    open func dataSourceDidChangeContent(_ dataSource: TTDataSource) {
        dataSourceDidChangeContent(dataSource, animationCompletion: nil)
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
        assert(cellController != nil, "cellController is nil, please do self.cellController = ...")
        guard let dataSource = self.dataSource else {
            return 0
        }
        
        // register only once per collectionView
        if (previousCollectionView != collectionView) {
            previousCollectionView = collectionView
            self.registeredCellIdentifiers = nil
        }
        
        return dataSource.numberOfSections()
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource!.numberOfItems(inSection: section)
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let content = dataSource![indexPath]
        let reuseIdentifier = cellController.reuseIdentifier(for: content)
        
        if registeredCellIdentifiers == nil {
            registeredCellIdentifiers = [String]()
        }
        
        if registeredCellIdentifiers?.contains(reuseIdentifier) == false {
            if let nib = cellController.nibToInstantiateCell(for: content) {
                collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
            } else {
                let cellClass: AnyClass? = cellController.classToInstantiateCell(for: content)
                collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
            }
            
            registeredCellIdentifiers?.append(reuseIdentifier)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        assert(cellController.acceptsContent(content), "Can't produce cell for content \(content)")
        assert(cell.reuseIdentifier == reuseIdentifier , "Cell returned from cell controller \(cellController) had reuseIdenfier \(cell.reuseIdentifier), which must be equal to the cell controller's reuseIdentifierForContent, which returned \(reuseIdentifier)")
        
        // pass parentViewController
        cell.parentViewController = cellController.parentViewController;
        
        cellController.configureCell(cell, for: content, at: indexPath)
        
        // so
        if let cellController = cellController as? TTCollectionCellControllerProtocolExtended {
            let sectionCount = dataSource!.numberOfItems(inSection: indexPath.section)
            cellController.configureCell(cell, for: content, at: indexPath, dataSourceCount: sectionCount)
        }
        
        
        if autoLoadMoreContent {
            //schedule on next run loop
            CFRunLoopPerformBlock(CFRunLoopGetMain(), CFRunLoopMode.commonModes as CFTypeRef!, {
                self.checkIfShouldLoadMoreContentForIndexPath(indexPath)
            })
        }
        
        return cell;
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let dataSource = self.dataSource else {
            return UICollectionReusableView()
        }
        
        // load more
        let showLoadMore = kind == UICollectionElementKindSectionFooter && canShowLoadMoreView
        if showLoadMore {
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadMoreViewXIBName, for: indexPath)
            if let loadMoreView = reusableView as? LoadMoreView {
                loadMoreView.loadingView?.isHidden = false
                loadMoreView.loadingView?.color = options.loadMoreIndicatorViewColor
                loadMoreView.startAnimating()
                
                dataSource.feed?.loadMore()
            }
            
            return reusableView
        }
        
        // header view
        let showHeader = kind == UICollectionElementKindSectionHeader
        if showHeader, let headerController = headerController  {
            let reuseIdentifier = headerController.reuseIdentifier
            if registeredCellIdentifiers == nil {
                registeredCellIdentifiers = [String]()
            }
            
            if registeredCellIdentifiers?.contains(reuseIdentifier) == false {
                if let nib = headerController.nibToInstantiate() {
                    collectionView.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
                } else {
                    let headerClass: AnyClass? = headerController.classToInstantiate()
                    collectionView.register(headerClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
                }
                
                registeredCellIdentifiers?.append(reuseIdentifier)
            }
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath)
            headerView.parentViewController = self
            let content = dataSource.sectionHeaderItem(at: indexPath.section)!
            headerController.configureHeader(headerView, for: content, at: indexPath)
            
            return headerView
        }
        
        assert(true, "Could not show load more view -> there is some bug in dataSource implementation as we should not get here")
        
        return UICollectionReusableView() // just to ingore compilation error
    }
    
    // TODO: support for headerCellController
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.parentViewController = nil
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.parentViewController = cellController.parentViewController
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

//    TODO: Fix should highlight
//    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: IndexPath) -> Bool {
//        if cellController.respondsToSelector(Selector("shouldHighlightContent:atIndexPath:")) {
//            let content = dataSource.objectAtIndexPath(indexPath)
//            return cellController.shouldHighlightContent!(content, atIndexPath: indexPath)
//        }
//
//        return true
//    }
//}
//
// MARK: Layout Size -
//extension CollectionFeedController {
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let content = dataSource![indexPath]
        let size = cellController.cellSize(for: content, in: collectionView)
        let boundsSize = collectionView.bounds.size
        return CGSize(width: size.width < 0.0 ? boundsSize.width : size.width, height: size.height < 0.0 ? boundsSize.height : size.height)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let dataSource = dataSource, dataSource.numberOfItems(inSection: section) > 0 {
            let content = dataSource[section, 0]
            return cellController.sectionInset(for: content, in: collectionView)
        } else {
            return UIEdgeInsets.zero
        }
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
        return ((canShowLoadMoreView && shouldShowLoadMore(section: section)) ? CGSize(width: 30, height: 40) : CGSize.zero)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection  section: Int) -> CGSize {
        if let dataSource = dataSource, dataSource.numberOfItems(inSection: section) > 0,
            let headerController = headerController,
            let item = dataSource.sectionHeaderItem(at: section), 
            headerController.acceptsContent(item) {
            return headerController.headerSize
        } else {
            return CGSize.zero
        }
    }
//}
//
//MARK: ForceTouch Delegate
//extension CollectionFeedController : UIViewControllerPreviewingDelegate {
    @available(iOS 9.0, *)
    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let point = collectionView!.convert(location, from: self.view)
        guard let indexPath = collectionView!.indexPathForItem(at: point) else {
            return nil
        }
        
        let content = dataSource![indexPath]
        var cellController = self.cellController
        let previousParentController = cellController?.parentViewController
        let parentController = UIViewController()
        var dummyNavigationController: DummyNavigationController? = DummyNavigationController(rootViewController: parentController)
        cellController?.parentViewController = parentController
        cellController?.didSelectContent(content, at: indexPath, in: collectionView!)
        cellController?.parentViewController = previousParentController
        
        let controller = dummyNavigationController!.capturedViewController
        dummyNavigationController = nil // destroy
        if let controller = controller {
            controller.preferredContentSize = CGSize.zero
            
            let cell = collectionView!.cellForItem(at: indexPath)
            previewingContext.sourceRect = cell!.convert(cell!.bounds, to:self.view)
        }
        
        return controller
    }
    
    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    internal class DummyNavigationController : UINavigationController {
        var capturedViewController: UIViewController?
        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            if !viewControllers.isEmpty {
                capturedViewController = viewController
            } else {
                super.pushViewController(viewController, animated: animated)
            }
        }
    }
    
    internal func registerForceTouchPreview() {
        if #available(iOS 9, *) {
            if traitCollection.forceTouchCapability == .available  && forceTouchPreviewContext == nil {
                forceTouchPreviewContext = registerForPreviewing(with: self, sourceView: self.view!)
            }
        }
    }
    internal func unregisterForceTouchPreview() {
        if #available(iOS 9, *) {
            if traitCollection.forceTouchCapability == .available {
                if forceTouchPreviewContext != nil {
                    unregisterForPreviewing(withContext: forceTouchPreviewContext!)
                    forceTouchPreviewContext = nil
                }
            }
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if forceTouchPreviewContext == nil && forceTouchPreviewEnabled {
            registerForceTouchPreview()
        }
    }
}
