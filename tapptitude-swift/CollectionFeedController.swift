//
//  CollectionFeedController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

@objc public class CollectionFeedController: UIViewController, TTCollectionFeedController {
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
                
                collectionView.registerNib(UINib(nibName: loadMoreViewXIBName, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: loadMoreViewXIBName)
                
                if !self.isScrollDirectionConfigured {
                    // fetch scrollDirection value from collectionView layout
                    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                        self.scrollDirection = layout.scrollDirection
                    }
                }
                updateCollectionViewScrollDirection()
            }
        }
    }
    
    @IBOutlet public weak var reloadIndicatorView: UIActivityIndicatorView?
    internal var _emptyView: UIView?
    @IBOutlet public var emptyView: UIView? { //set from XIB or overwrite
        set {
            _emptyView = newValue
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
            noContent.text = NSLocalizedString("No content", comment: "No content")
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
    
    public var cellController: TTCollectionCellControllerProtocol! {
        willSet {
            cellController?.parentViewController = nil
        }
        didSet {
            cellController.parentViewController = self
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
    
    
    
    public func scrollToContent(content: AnyObject!, animated: Bool) {
        guard let collectionView = self.collectionView, let dataSource = self.dataSource else {
            return
        }
        
        if let indexPath = dataSource.indexPathForObject(content) {
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
    
    /* Load More */
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
        
        print("showLoadMore = \(showLoadMore)")
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
        let feed = self.dataSource?.feed
        if autoLoadMoreContent && supportsLoadMore && feed?.canLoadMore == true {
            if let indexPath = collectionView?.indexPathsForVisibleItems().last {
                self.checkIfShouldLoadMoreContentForIndexPath(indexPath)
            } else {
                dataSource?.feed?.loadMore()
            }
        }
    }
    
    internal func checkIfShouldLoadMoreContentForIndexPath(indexPath:NSIndexPath?) {  //Future - indexPath used for identifying section
        guard let feed = self.dataSource?.feed else {
            return
        }
        
        guard indexPath != nil && supportsLoadMore && feed.canLoadMore == true else {
            return
        }
        
        guard let collectionView = self.collectionView else {
            return
        }
        
        if shouldShowLoadMoreForSection(indexPath!.section) {
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
    
    
    
    
    /* Force Touch Preview */
    public var forceTouchPreviewEnabled: Bool = false {
        didSet {
            if !isViewLoaded() {
                return
            }
            
            if (self.forceTouchPreviewEnabled) {
                registerForceTouchPreview()
            } else {
                unregisterForceTouchPreview()
            }
        }
    }
    internal func registerForceTouchPreview() {
        // TODO: implement into an extensions
    }
    internal func unregisterForceTouchPreview() {
        // TODO: implement into an extensions
    }
    
    /* Pull to Refresh functionality */
    @IBOutlet public  weak var refreshControl: UIRefreshControl?
    public func pullToRefreshAction(sender: AnyObject!) {
        dataSource?.feed?.reload()
    }
    public func addPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = collectionView?.backgroundColor
        refreshControl.addTarget(self, action: Selector("pullToRefreshAction:"), forControlEvents: .ValueChanged)
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
}


extension CollectionFeedController : TTDataFeedDelegate {
    public func dataFeed(dataFeed: TTDataFeed?, failedWithError error: NSError) {
        refreshControl?.endRefreshing()
    }
    
    public func dataFeed(dataFeed: TTDataFeed?, didReloadContent content: [AnyObject]?) {
        refreshControl?.endRefreshing()
    }
    
    public func dataFeed(dataFeed: TTDataFeed?, didLoadMoreContent content: [AnyObject]?) {
        
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
}



extension CollectionFeedController : TTDataSourceDelegate {
    public func dataSourceDidReloadContent(dataSource: TTDataSource) {
        reloadDataOnCollectionView()
    }
    
    public func dataSourceDidLoadMoreContent(dataSource: TTDataSource) {
        reloadDataOnCollectionView()
    }
}

//extension CollectionFeedController : TTDataSourceIncrementalChangesDelegate {
//    func dataSourceWillChangeContent(dataSource: TTDataSource) {
//
//    }
//
//    func dataSourceDidChangeContent(dataSource: TTDataSource) {
//        reloadDataOnCollectionView()
//
//        if dataSource.feed?.isReloading == true { // check for the empty view
//            updateEmptyViewAppearenceAnimated(true)
//        }
//    }
//}

extension CollectionFeedController : UICollectionViewDataSource {
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
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
        return dataSource!.numberOfRowsInSection(section)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let content = dataSource!.objectAtIndexPath(indexPath)
        let reuseIdentifier = cellController.reuseIdentifierForContent(content)
        
        if registeredCellIdentifiers == nil {
            registeredCellIdentifiers = [String]()
        }
        
        if registeredCellIdentifiers?.contains(reuseIdentifier) == false {
            if let cellClass = cellController.classToInstantiateCellForContent(content) {
                collectionView.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
            } else {
                let nib = cellController.nibToInstantiateCellForContent(content)
                collectionView.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
            }
            
            registeredCellIdentifiers?.append(reuseIdentifier)
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        assert(cellController.acceptsContent(content), "Can't produce cell for content \(content)")
        assert(cell.reuseIdentifier == reuseIdentifier , "Cell returned from cell controller \(cellController) had reuseIdenfier \(cell.reuseIdentifier), which must be equal to the cell controller's reuseIdentifierForContent, which returned \(reuseIdentifier)")
        
        // pass parentViewController
        cell.tt_parentViewController = cellController.parentViewController;
        
        //        if cellController.respondsToSelector(Selector("configureCell:forContent:indexPath:dataSourceCount:")) {
        //            let sectionCount = dataSource.numberOfRowsInSection(indexPath.section)
        //            cellController.configureCell?(cell, forContent: content, indexPath: indexPath, dataSourceCount: sectionCount)
        //        } else {
        cellController.configureCell(cell, forContent: content, indexPath: indexPath)
        //        }
        
        
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
        
        let showLoadMore = kind == UICollectionElementKindSectionFooter && canShowLoadMoreView
        if showLoadMore {
            let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: loadMoreViewXIBName, forIndexPath: indexPath)
            if let loadMoreView = reusableView as? LoadMoreView {
                loadMoreView.loadingView?.hidden = false
                loadMoreView.startAnimating()
                
                dataSource.feed?.loadMore()
            }
            
            return reusableView
        }
        
        assert(true, "Could not show load more view -> there is some bug in dataSource implementation as we should not get here")
        
        return UICollectionReusableView() // just to ingore compilation error
    }
    
    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.tt_parentViewController = nil
    }
}




extension CollectionFeedController {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let content = dataSource!.objectAtIndexPath(indexPath)
        cellController.didSelectContent(content, indexPath: indexPath, collectionView: collectionView)
    }
    
    //    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    //        guard let dataSource = self.dataSource else {
    //            return false
    //        }
    //
    //        if cellController.respondsToSelector(Selector("shouldHighlightContent:atIndexPath:")) {
    //            let content = dataSource.objectAtIndexPath(indexPath)
    //            return cellController.shouldHighlightContent!(content, atIndexPath: indexPath)
    //        }
    //
    //        return true
    //    }
}

extension CollectionFeedController {
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let content = dataSource!.objectAtIndexPath(indexPath)
        let size = cellController.cellSizeForContent(content, collectionView: collectionView)
        let boundsSize = collectionView.bounds.size
        return CGSizeMake(size.width < 0.0 ? boundsSize.width : size.width, size.height < 0.0 ? boundsSize.height : size.height)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if dataSource?.numberOfRowsInSection(section) > 0 {
            let content = dataSource!.objectAtIndexPath(NSIndexPath(forItem: 0, inSection: section))
            return cellController.sectionInsetForContent(content, collectionView: collectionView)
        } else {
            return UIEdgeInsetsZero
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        if dataSource?.numberOfRowsInSection(section) > 0 {
            let content = dataSource!.objectAtIndexPath(NSIndexPath(forItem: 0, inSection: section))
            return cellController.minimumInteritemSpacingForContent(content, collectionView: collectionView)
        } else {
            return 0.0
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if dataSource?.numberOfRowsInSection(section) > 0 {
            let content = dataSource!.objectAtIndexPath(NSIndexPath(forItem: 0, inSection: section))
            return cellController.minimumLineSpacingForContent(content, collectionView: collectionView)
        } else {
            return 0.0
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return ((canShowLoadMoreView && shouldShowLoadMoreForSection(section)) ? CGSizeMake(30, 40) : CGSizeZero)
    }
}