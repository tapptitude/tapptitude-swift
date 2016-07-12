//
//  CollectionFeedController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

public class CollectionFeedController: UIViewController, TTCollectionFeedController, TTCollectionFeedControllerMutable, TTDataFeedDelegate, TTDataSourceDelegate, UIViewControllerPreviewingDelegate {
    
    public struct Options {
        public var emptyMessage = NSLocalizedString("No content", comment: "No content")
        public var loadMoreIndicatorViewColor = UIColor.grayColor()
    }
    
    public var options = Options()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        updateReloadingIndicatorView()
        updateEmptyViewAppearenceAnimated(false)
        if forceTouchPreviewEnabled {
            registerForceTouchPreview()
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        updateReloadingIndicatorView()
        updateEmptyViewAppearenceAnimated(false)
    }
    
    internal var registeredCellIdentifiers : [String]?
    internal var isScrollDirectionConfigured : Bool = false
    internal weak var previousCollectionView : UICollectionView! = nil
    
    @IBOutlet public weak var collectionView: UICollectionView? {
        willSet {
            collectionView?.dataSource = nil
            collectionView?.delegate = nil
        }
        
        didSet {
            registeredCellIdentifiers = nil
            
            if let collectionView = self.collectionView {
                collectionView.delegate = self
                collectionView.dataSource = self
                
                let nib = UINib(nibName: loadMoreViewXIBName, bundle: NSBundle(forClass: CollectionFeedController.self))
                collectionView.registerNib(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: loadMoreViewXIBName)
                
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
    
    @IBOutlet public weak var reloadIndicatorView: UIActivityIndicatorView?
    internal var _emptyView: UIView?
    @IBOutlet public var emptyView: UIView? { //set from XIB or overwrite
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
            noContent.backgroundColor = UIColor.clearColor()
            noContent.text = options.emptyMessage
            noContent.frame = CGRectIntegral(collectionView!.frame)
            noContent.textAlignment = .Center
            noContent.numberOfLines = 0
            noContent.textColor = UIColor(white: 0.4, alpha: 1.0)
            noContent.autoresizingMask = collectionView!.autoresizingMask
            
            return noContent;
        }
    }
    
    public var dataSource: TTDataSource? {
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
    
    public var dataSourceMutable: TTDataSourceMutable? {
        return dataSource as? TTDataSourceMutable
    }
    
    public var cellController: TTCollectionCellControllerProtocol! {
        willSet {
            cellController?.parentViewController = nil
        }
        didSet {
            cellController.parentViewController = self
            updateCollectionViewLayoutAttributes()
        }
    }
    
    public var headerController: TTCollectionHeaderControllerProtocol? {
        willSet {
            headerController?.parentViewController = nil
        }
        didSet {
            headerController?.parentViewController = self
        }
    }
    
    public var headerIsSticky = false {
        didSet {
            if #available(iOS 9.0, *) {
                (self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).sectionHeadersPinToVisibleBounds = headerIsSticky
            }
        }
    }
    
    public var scrollDirection: UICollectionViewScrollDirection = .Vertical {
        didSet {
            isScrollDirectionConfigured = true
            updateCollectionViewScrollDirection()
        }
    }
    internal func updateCollectionViewScrollDirection() {
        let verticalScroll = (self.scrollDirection == .Vertical)
        let horizontalScroll = (self.scrollDirection == .Horizontal)
        
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
    public func updateEmptyViewAppearenceAnimated(animated: Bool) {
        let feedIsLoading = (dataSource?.feed?.isReloading == true) || (dataSource?.feed?.isLoadingMore == true)
        let hasContent = dataSource?.hasContent() == true
        
        if (feedIsLoading || hasContent) && displayedEmptyView != nil {
            if animated {
                let emptyView = displayedEmptyView
                displayedEmptyView = nil
                UIView.animateWithDuration(0.3, animations: { () -> Void in
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
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.displayedEmptyView?.alpha = 1.0
                })
            }
        }
    }
    
    public func updateReloadingIndicatorView() {
        guard let dataSource = self.dataSource else {
            reloadIndicatorView?.stopAnimating()
            return
        }
        
        if dataSource.feed?.isReloading == true {
            if hideReloadViewIfHasContent && dataSource.hasContent() {
                
            } else {
                if refreshControl == nil || (refreshControl?.refreshing == false) {
                    reloadIndicatorView?.startAnimating()
                }
            }
        } else {
            reloadIndicatorView?.stopAnimating()
        }
    }
    public var hideReloadViewIfHasContent: Bool = true
    
    
    
    public func scrollToElement(element: Any!, animated: Bool) {
        guard let collectionView = self.collectionView, let dataSource = self.dataSource else {
            return
        }
        
        if let indexPath = dataSource.indexPath(of: element) {
            let layout = collectionView.collectionViewLayout
            var attribute = layout.layoutAttributesForItemAtIndexPath(indexPath)
            if attribute?.frame.size.width < 1.0 {
                layout.prepareLayout()
                attribute = layout.layoutAttributesForItemAtIndexPath(indexPath)
                collectionView.contentSize = layout.collectionViewContentSize()
            }
            
            if attribute != nil {
                collectionView.scrollRectToVisible(attribute!.frame, animated: animated)
            }
        }
    }
    
    //MARK: Load More -
    public var supportsLoadMore: Bool = true
    public var autoLoadMoreContent: Bool = true
    public var numberOfPagesToPreload: Int = 2 // load more content when last 2 pages are visible
    public var canShowLoadMoreView : Bool = false
    public func shouldShowLoadMoreForSection(section: Int) -> Bool { // default - YES only for last section
        return (dataSource != nil && (section == dataSource!.numberOfSections() - 1))
    }
    
    public var loadMoreViewXIBName: String! = "LoadMoreView" // Expected same methods as in LoadMoreView
    internal func updateCanShowLoadMoreViewAnimated(animated:Bool) {
        let feed = self.dataSource?.feed
        let showLoadMore = supportsLoadMore && (feed?.canLoadMore == true || feed?.isLoadingMore == true)
        
        if feed != nil {
            print("showLoadMore = \(showLoadMore)")
        }
        if canShowLoadMoreView != showLoadMore {
            if animated && collectionView?.indexPathsForVisibleItems().count > 0 {
                collectionView?.performBatchUpdates({ () -> Void in
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
    
    public func checkIfShouldLoadMoreContent() {
        guard let collectionView = collectionView, feed = dataSource?.feed else {
            return
        }
        
        if autoLoadMoreContent && supportsLoadMore && feed.canLoadMore == true {
            if let indexPath = collectionView.indexPathsForVisibleItems().last {
                self.checkIfShouldLoadMoreContentForIndexPath(indexPath)
            } else if dataSource?.hasContent() == false {
                feed.loadMore()
            }
        }
    }
    
    internal func checkIfShouldLoadMoreContentForIndexPath(indexPath: NSIndexPath?) {  //Future - indexPath used for identifying section
        guard let feed = self.dataSource?.feed, indexPath = indexPath, collectionView = collectionView else {
            return
        }
        
        guard supportsLoadMore && feed.canLoadMore == true else {
            return
        }
        
        if shouldShowLoadMoreForSection(indexPath.section) {
            var preloadMoreContent = false
            let bounds = collectionView.bounds
            let contentSize = collectionView.contentSize
            let numberOfPagesToPreload = CGFloat(self.numberOfPagesToPreload)
            
            if scrollDirection == .Vertical {
                preloadMoreContent = (contentSize.height - CGRectGetMaxY(bounds)) < (numberOfPagesToPreload * bounds.size.height)
            } else  {
                preloadMoreContent = (contentSize.width - CGRectGetMaxX(bounds)) < (numberOfPagesToPreload * bounds.size.width)
            }
            
            if preloadMoreContent {
                feed.loadMore()
            }
        }
    }
    
    
    //MARK: ForceTouch Preview -
    internal weak var forceTouchPreviewContext: UIViewControllerPreviewing?
    public var forceTouchPreviewEnabled: Bool = false {
        didSet {
            if !isViewLoaded() {
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
    @IBOutlet public  weak var refreshControl: UIRefreshControl?
    public func pullToRefreshAction(sender: AnyObject!) {
        dataSource?.feed?.reload()
    }
    public func addPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = collectionView?.backgroundColor
        refreshControl.addTarget(self, action: #selector(CollectionFeedController.pullToRefreshAction(_:)), forControlEvents: .ValueChanged)
        self.refreshControl = refreshControl
        collectionView?.addSubview(refreshControl)
    }
    
    internal func reloadDataOnCollectionView() {
        // apple bug, after reload, collectionview calls unhighlight on cells that where removed from superview.
        let method = "_" + "unhighlightAllItems"
        let selector = Selector(method)
        if collectionView?.respondsToSelector(selector) == true {
            collectionView?.performSelector(selector)
        }
        collectionView?.reloadData()
    }
    
    
    public var animatedUpdates = false
    private var animatedUpdater: CollectionViewAnimatedUpdater?
//}
//
//
////MARK: Data Feed -
//extension CollectionFeedController : TTDataFeedDelegate {
    public func dataFeed(dataFeed: TTDataFeed?, failedWithError error: NSError) {
        refreshControl?.endRefreshing()
    }
    
    public func dataFeed(dataFeed: TTDataFeed?, didReloadContent content: [Any]?) {
        refreshControl?.endRefreshing()
    }
    
    public func dataFeed(dataFeed: TTDataFeed?, didLoadMoreContent content: [Any]?) {
        
    }
    
    public func dataFeed(dataFeed: TTDataFeed?, isReloading: Bool) {
        checkIfShouldLoadMoreContent()
        updateReloadingIndicatorView()
        updateCanShowLoadMoreViewAnimated(true)
        updateEmptyViewAppearenceAnimated(true)
    }
    
    public func dataFeed(dataFeed: TTDataFeed?, isLoadingMore: Bool) {
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
    public func dataSourceWillChangeContent(dataSource: TTDataSource) {
        if let collectionView = collectionView {
            animatedUpdater = animatedUpdates ? CollectionViewAnimatedUpdater() : nil
            animatedUpdater?.collectionViewWillChangeContent(collectionView)
        } else {
            animatedUpdater = nil
        }
    }

    public func dataSourceDidChangeContent(dataSource: TTDataSource) {
        if animatedUpdater == nil {
            reloadDataOnCollectionView()
        } else {
            animatedUpdater?.collectionViewDidChangeContent(collectionView!)
        }

        if dataSource.feed == nil || dataSource.feed!.isReloading == false { // check for the empty view
            updateEmptyViewAppearenceAnimated(true)
        }
        
        animatedUpdater = nil
    }
    
    public func dataSource(dataSource: TTDataSource, didUpdateItemsAt indexPaths: [NSIndexPath]) {
        animatedUpdater?.collectionView(collectionView!, didUpdateItemsAt: indexPaths)
    }
    
    public func dataSource(dataSource: TTDataSource, didDeleteItemsAt indexPaths: [NSIndexPath]) {
        animatedUpdater?.collectionView(collectionView!, didDeleteItemsAt: indexPaths)
    }
    
    public func dataSource(dataSource: TTDataSource, didInsertItemsAt indexPaths: [NSIndexPath]) {
        animatedUpdater?.collectionView(collectionView!, didInsertItemsAt: indexPaths)
    }
    
    public func dataSource(dataSource: TTDataSource, didMoveItemsFrom fromIndexPaths: [NSIndexPath], to toIndexPaths: [NSIndexPath]) {
        animatedUpdater?.collectionView(collectionView!, didMoveItemsFrom: fromIndexPaths, to: toIndexPaths)
    }
    
    public func dataSource(dataSource: TTDataSource, didInsertSections addedSections: NSIndexSet) {
        animatedUpdater?.collectionView(collectionView!, didInsertSections: addedSections)
    }
    public func dataSource(dataSource: TTDataSource, didDeleteSections deletedSections: NSIndexSet) {
        animatedUpdater?.collectionView(collectionView!, didDeleteSections: deletedSections)
    }
    public func dataSource(dataSource: TTDataSource, didUpdateSections updatedSections: NSIndexSet) {
        animatedUpdater?.collectionView(collectionView!, didUpdateSections: updatedSections)
    }
//}
//
// MARK: Data Source -
//extension CollectionFeedController : UICollectionViewDataSource {
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
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
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource!.numberOfItems(inSection: section)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let content = dataSource![indexPath]
        let reuseIdentifier = cellController.reuseIdentifierForContent(content)
        
        if registeredCellIdentifiers == nil {
            registeredCellIdentifiers = [String]()
        }
        
        if registeredCellIdentifiers?.contains(reuseIdentifier) == false {
            if let nib = cellController.nibToInstantiateCellForContent(content) {
                collectionView.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
            } else {
                let cellClass: AnyClass? = cellController.classToInstantiateCellForContent(content)
                collectionView.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
            }
            
            registeredCellIdentifiers?.append(reuseIdentifier)
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        assert(cellController.acceptsContent(content), "Can't produce cell for content \(content)")
        assert(cell.reuseIdentifier == reuseIdentifier , "Cell returned from cell controller \(cellController) had reuseIdenfier \(cell.reuseIdentifier), which must be equal to the cell controller's reuseIdentifierForContent, which returned \(reuseIdentifier)")
        
        // pass parentViewController
        cell.parentViewController = cellController.parentViewController;
        
        cellController.configureCell(cell, forContent: content, indexPath: indexPath)
        
        // so
        if let cellController = cellController as? TTCollectionCellControllerProtocolExtended {
            let sectionCount = dataSource!.numberOfItems(inSection: indexPath.section)
            cellController.configureCell(cell, forContent: content, indexPath: indexPath, dataSourceCount: sectionCount)
        }
        
        
        if autoLoadMoreContent {
            //schedule on next run loop
            CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, {
                self.checkIfShouldLoadMoreContentForIndexPath(indexPath)
            })
        }
        
        return cell;
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        guard let dataSource = self.dataSource else {
            return UICollectionReusableView()
        }
        
        // load more
        let showLoadMore = kind == UICollectionElementKindSectionFooter && canShowLoadMoreView
        if showLoadMore {
            let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: loadMoreViewXIBName, forIndexPath: indexPath)
            if let loadMoreView = reusableView as? LoadMoreView {
                loadMoreView.loadingView?.hidden = false
                loadMoreView.loadingView?.color = options.loadMoreIndicatorViewColor
                loadMoreView.startAnimating()
                
                dataSource.feed?.loadMore()
            }
            
            return reusableView
        }
        
        // header view
        let showHeader = kind == UICollectionElementKindSectionHeader && headerController != nil
        if showHeader {
            let reuseIdentifier = headerController!.reuseIdentifier
            if registeredCellIdentifiers == nil {
                registeredCellIdentifiers = [String]()
            }
            
            if registeredCellIdentifiers?.contains(reuseIdentifier) == false {
                if let nib = headerController!.nibToInstantiate() {
                    collectionView.registerNib(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
                } else {
                    let headerClass: AnyClass? = headerController!.classToInstantiate()
                    collectionView.registerClass(headerClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
                }
                
                registeredCellIdentifiers?.append(reuseIdentifier)
            }
            
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: reuseIdentifier, forIndexPath: indexPath)
            headerView.parentViewController = self
            let content = dataSource[indexPath]
            headerController!.configureHeader(headerView, forContent: content, indexPath: indexPath)
            
            return headerView
        }
        
        assert(true, "Could not show load more view -> there is some bug in dataSource implementation as we should not get here")
        
        return UICollectionReusableView() // just to ingore compilation error
    }
    
    // TODO: support for headerCellController
    
    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.parentViewController = nil
    }
//}
//
//
//
// MARK: Did Select -
//extension CollectionFeedController {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let content = dataSource![indexPath]
        cellController.didSelectContent(content, indexPath: indexPath, collectionView: collectionView)
    }

//    TODO: Fix should highlight
//    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
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
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let content = dataSource![indexPath]
        let size = cellController.cellSizeForContent(content, collectionView: collectionView)
        let boundsSize = collectionView.bounds.size
        return CGSizeMake(size.width < 0.0 ? boundsSize.width : size.width, size.height < 0.0 ? boundsSize.height : size.height)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if dataSource?.numberOfItems(inSection: section) > 0 {
            let content = dataSource![section, 0]
            return cellController.sectionInsetForContent(content, collectionView: collectionView)
        } else {
            return UIEdgeInsetsZero
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        if dataSource?.numberOfItems(inSection: section) > 0 {
            let content = dataSource![section, 0]
            return cellController.minimumInteritemSpacingForContent(content, collectionView: collectionView)
        } else {
            return 0.0
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if dataSource?.numberOfItems(inSection: section) > 0 {
            let content = dataSource![section, 0]
            return cellController.minimumLineSpacingForContent(content, collectionView: collectionView)
        } else {
            return 0.0
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return ((canShowLoadMoreView && shouldShowLoadMoreForSection(section)) ? CGSizeMake(30, 40) : CGSizeZero)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection  section: Int) -> CGSize {
        let showHeader = headerController != nil && self.dataSource?.numberOfItems(inSection: section) > 0
        if showHeader && headerController!.acceptsContent(dataSource![section, 0]) {
            return headerController!.headerSize
        } else {
            return CGSizeZero
        }
    }
//}
//
//MARK: ForceTouch Delegate
//extension CollectionFeedController : UIViewControllerPreviewingDelegate {
    @available(iOS 9.0, *)
    public func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let point = collectionView!.convertPoint(location, fromView: self.view)
        guard let indexPath = collectionView!.indexPathForItemAtPoint(point) else {
            return nil
        }
        
        let content = dataSource![indexPath]
        let previousParentController = cellController.parentViewController
        let parentController = UIViewController()
        var dummyNavigationController: DummyNavigationController? = DummyNavigationController(rootViewController: parentController)
        cellController.parentViewController = parentController
        cellController.didSelectContent(content, indexPath: indexPath, collectionView: collectionView!)
        cellController.parentViewController = previousParentController
        
        let controller = dummyNavigationController!.capturedViewController
        dummyNavigationController = nil // destroy
        if let controller = controller {
            controller.preferredContentSize = CGSizeZero
            
            let cell = collectionView!.cellForItemAtIndexPath(indexPath)
            previewingContext.sourceRect = cell!.convertRect(cell!.bounds, toView:self.view)
        }
        
        return controller
    }
    
    public func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
    
    internal class DummyNavigationController : UINavigationController {
        var capturedViewController: UIViewController?
        override func pushViewController(viewController: UIViewController, animated: Bool) {
            capturedViewController = viewController
        }
    }
    
    internal func registerForceTouchPreview() {
        if #available(iOS 9, *) {
            if traitCollection.forceTouchCapability == .Available {
                forceTouchPreviewContext = registerForPreviewingWithDelegate(self, sourceView: self.view!)
            }
        }
    }
    internal func unregisterForceTouchPreview() {
        if #available(iOS 9, *) {
            if traitCollection.forceTouchCapability == .Available {
                if forceTouchPreviewContext != nil {
                    unregisterForPreviewingWithContext(forceTouchPreviewContext!)
                    forceTouchPreviewContext = nil
                }
            }
        }
    }
    
    public override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if forceTouchPreviewContext == nil && forceTouchPreviewEnabled {
            registerForceTouchPreview()
        }
    }
}