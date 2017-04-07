//
//  CollectionFeedViewController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

public protocol TTCollectionFeedController : class, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var dataSource: TTDataSource? {get set}
    var cellController: TTAnyCollectionCellController! {get set}
    
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
