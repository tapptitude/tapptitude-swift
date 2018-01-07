//
//  CollectionFeedViewController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

public protocol TTCollectionFeedController : class, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var _dataSource: TTAnyDataSource? {get set}
    var _cellController: TTAnyCollectionCellController! {get set}
    
    weak var collectionView: UICollectionView! {get set}

    var scrollDirection: UICollectionViewScrollDirection {get set}
    
    weak var reloadIndicatorView: UIActivityIndicatorView? {get set}
    var emptyView: UIView? {get set} //set from XIB or overwrite
    
    
    /* Pull to Refresh functionality */
    weak var refreshControl: UIRefreshControl? {get set}
    func pullToRefreshAction(_ sender: AnyObject!)
    func addPullToRefresh()
    
    var loadMoreController: TTLoadMoreController? { get set }
    
    // helpers
    func scrollToElement<T>(ofFirst filter: (_ item: T) -> Bool, animated: Bool)
}















extension TTCollectionFeedController {
    public func scrollToElement<T>(ofFirst filter: (_ item: T) -> Bool, animated: Bool) {
        if let indexPath = _dataSource!.indexPath(ofFirst: filter) {
            let layout = collectionView.collectionViewLayout
            var attribute = layout.layoutAttributesForItem(at: indexPath)
            if (attribute?.frame.size.width ?? 0.0) < 1.0 {
                layout.prepare()
                attribute = layout.layoutAttributesForItem(at: indexPath)
                collectionView.contentSize = layout.collectionViewContentSize
            }
            
            if let attribute = attribute {
                collectionView.scrollRectToVisible(attribute.frame, animated: animated)
            }
        }
    }
}
