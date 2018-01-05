//
//  LoadMoreController.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 02/04/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import UIKit

extension TTLoadMoreController {
    public func checkIfShouldLoadMoreContent(for feed: TTDataFeed?) {
        guard let feed = feed, let collectionView = collectionView else {
            return
        }
        
        guard autoLoadMoreContent && feed.canLoadMore == true else {
            return
        }
        
        var preloadMoreContent = false
        let numberOfPagesToPreload = self.numberOfPagesToPreload
        let bounds = collectionView.bounds
        let contentSize = collectionView.contentSize
        
        switch loadMorePosition {
        case .bottom: preloadMoreContent = (contentSize.height - bounds.maxY) < (numberOfPagesToPreload * bounds.size.height)
        case .right: preloadMoreContent = (contentSize.width - bounds.maxX) < (numberOfPagesToPreload * bounds.size.width)
        case .top: preloadMoreContent = bounds.origin.y < (numberOfPagesToPreload * bounds.size.height)
        case .left: preloadMoreContent = bounds.origin.x < (numberOfPagesToPreload * bounds.size.width)
        }
        
        if preloadMoreContent {
            feed.loadMore()
        }
    }
    
    public func shouldShowLoadMoreViewInSection(_ section: Int, collectionView: UICollectionView) -> Bool {
        guard canShowLoadMoreView else {
            return false
        }
        
        switch self.loadMorePosition {
        case .top, .left: return section == 0
        case .bottom, .right:  return  section == collectionView.numberOfSections - 1
        }
    }
}








open class LoadMoreFooterController: NSObject, TTLoadMoreController {
    open var autoLoadMoreContent: Bool = true
    open var numberOfPagesToPreload: CGFloat = 2 // load more content when last 2 pages are visible
    open var canShowLoadMoreView : Bool = false
    open var loadMorePosition = LoadMoreController.Position.bottom
    
    @IBOutlet public var collectionView: UICollectionView? {
        didSet {
            if let collectionView = collectionView {
                self.registLoadMoreView(in: collectionView)
            }
        }
    }
    
    public func sizeForLoadMoreViewInSection(_ section: Int, collectionView: UICollectionView) -> CGSize {
        return shouldShowLoadMoreViewInSection(section, collectionView: collectionView) ? CGSize(width: 30, height: 40) : CGSize.zero
    }
    
    open var loadMoreViewXIBName: String! = "LoadMoreView" { // Expected same methods as in LoadMoreView
        didSet {
            if let collectionView = collectionView {
                self.registLoadMoreView(in: collectionView)
            }
        }
    }
    open func registLoadMoreView(in collectionView: UICollectionView) {
        let isInTappLibrary = Bundle(for: __CollectionFeedController.self).path(forResource: loadMoreViewXIBName, ofType: "nib") != nil
        let bundle: Bundle? = isInTappLibrary ? Bundle(for: __CollectionFeedController.self) : nil
        let nib = UINib(nibName: loadMoreViewXIBName, bundle: bundle)
        collectionView.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: loadMoreViewXIBName)
    }

    open func loadMoreView(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionReusableView? {
        // load more
        let kind = UICollectionElementKindSectionFooter
        if shouldShowLoadMoreViewInSection(indexPath.section, collectionView: collectionView) {
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadMoreViewXIBName, for: indexPath)
            if let loadMoreView = reusableView as? LoadMoreView {
                loadMoreView.loadingView?.isHidden = false
//                loadMoreView.loadingView?.color = options.loadMoreIndicatorViewColor
                loadMoreView.startAnimating()

//                dataSource.feed?.loadMore()
            }

            return reusableView
        }
        
        return nil
    }
    
    open func updateCanShowLoadMoreView(for feed: TTDataFeed?,  animated: Bool) {
        let showLoadMore = (feed?.canLoadMore == true || feed?.isLoadingMore == true)
        
        if feed != nil {
            print("showLoadMore = \(showLoadMore)")
        }
        if canShowLoadMoreView != showLoadMore {
            canShowLoadMoreView = showLoadMore
            
            if let collectionView = collectionView {
                if animated {
                    collectionView.performBatchUpdates({
                        collectionView.collectionViewLayout.invalidateLayout()
                    }, completion: nil)
                } else {
                    collectionView.collectionViewLayout.invalidateLayout()
                }
            }
            print("canShowLoadMoreView = \(canShowLoadMoreView)")
        }
    }
    
    open func updateLoadMoreViewPosition(in collectionView: UICollectionView) {
        
    }
    
    open func adjustSectionInsetToShowLoadMoreView(sectionInset: UIEdgeInsets, collectionView: UICollectionView, section: Int) -> UIEdgeInsets {
        return sectionInset
    }
}




open class LoadMoreController: NSObject, TTLoadMoreController {
    public enum Position {
        case top
        case left
        case bottom
        case right
    }
    
    @IBOutlet var loadMoreView: UIView! = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.hidesWhenStopped = true
        spinner.frame.size = CGSize(width: 30, height: 40)
        return spinner
    }()
    
    @IBOutlet open var collectionView: UICollectionView? {
        willSet {
            if canShowLoadMoreView {
                canShowLoadMoreView = false
//                updateScrollViewContentInset()
            }
            loadMoreView.removeFromSuperview()
        }
        didSet {
            collectionView?.addSubview(loadMoreView)
        }
    }
    
    open var loadMorePosition = Position.bottom
    open var autoLoadMoreContent: Bool = true
    open var numberOfPagesToPreload: CGFloat = 2 // load more content when last 2 pages are visible
    open var canShowLoadMoreView : Bool = false
    
    open func updateCanShowLoadMoreView(for feed: TTDataFeed?,  animated: Bool) {
        let showLoadMore = (feed?.canLoadMore == true || feed?.isLoadingMore == true)
        
        if feed != nil {
            print("showLoadMore = \(showLoadMore)")
        }
        if canShowLoadMoreView != showLoadMore {
            canShowLoadMoreView = showLoadMore
            let actitivyIndicator = loadMoreView as? UIActivityIndicatorView
            canShowLoadMoreView ? actitivyIndicator?.startAnimating() : actitivyIndicator?.stopAnimating()
            
//            if animated {
//                UIView.animate(withDuration: 0.3, animations: self.updateScrollViewContentInset)
//            } else {
//                updateScrollViewContentInset()
//            }
            if animated {
                collectionView?.performBatchUpdates({
                    self.collectionView?.collectionViewLayout.invalidateLayout()
                }, completion: nil)
            } else {
                collectionView?.collectionViewLayout.invalidateLayout()
            }
            print("canShowLoadMoreView = \(canShowLoadMoreView)")
        }
    }
    
    public func updateLoadMoreViewPosition(in collectionView: UICollectionView) {
        self.updateLoadMoreViewPosition()
    }
    
    func updateLoadMoreViewPosition() {
        guard let collectionView = collectionView else {
            return
        }
        
        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
        
        switch loadMorePosition {
        case .bottom: loadMoreView.center = CGPoint(x: collectionView.bounds.midX, y: contentSize.height - loadMoreView.bounds.midY)
        case .right: loadMoreView.center = CGPoint(x: contentSize.width - loadMoreView.bounds.midX, y: collectionView.bounds.midY)
        case .top: loadMoreView.center = CGPoint(x: collectionView.bounds.midX, y: loadMoreView.bounds.midY)
        case .left: loadMoreView.center = CGPoint(x: loadMoreView.bounds.midX, y: collectionView.bounds.midY)
        }
    }
    
//    open func updateScrollViewContentInset() {
//        guard let scrollView = collectionView else {
//            return
//        }
//        
//        let show: CGFloat = canShowLoadMoreView ? 1 : -1
//        switch loadMorePosition {
//        case .top: scrollView.contentInset.top += show * loadMoreView.bounds.height
//        case .bottom: scrollView.contentInset.bottom += show * loadMoreView.bounds.height
//        case .left: scrollView.contentInset.left += show * loadMoreView.bounds.width
//        case .right: scrollView.contentInset.right += show * loadMoreView.bounds.width
//        }
//    }
    
    
    
    open func adjustSectionInsetToShowLoadMoreView(sectionInset: UIEdgeInsets, collectionView: UICollectionView, section: Int) -> UIEdgeInsets {
        guard shouldShowLoadMoreViewInSection(section, collectionView: collectionView) else {
            return sectionInset
        }
        
        var insets = sectionInset
        switch (loadMorePosition, section) {
        case (.top, 0): insets.top += loadMoreView.bounds.height
        case (.left, 0): insets.left += loadMoreView.bounds.width
        case (.bottom, collectionView.numberOfSections - 1): insets.bottom += loadMoreView.bounds.height
        case (.right, collectionView.numberOfSections - 1): insets.right += loadMoreView.bounds.width
        default:
            break
        }
        return insets
    }
    
    
    public func sizeForLoadMoreViewInSection(_ section: Int, collectionView: UICollectionView) -> CGSize {
        return .zero
    }
    
    public func loadMoreView(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionReusableView? {
        return nil
    }
}


