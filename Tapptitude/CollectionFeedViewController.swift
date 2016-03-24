//
//  CollectionFeedViewController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

protocol TTCollectionFeedController : class, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var dataSource: TTDataSource? {get set}
    var cellController: TTCollectionCellControllerProtocol! {get set}
    
    weak var collectionView: UICollectionView? {get set}

    var scrollDirection: UICollectionViewScrollDirection {get set}
    
    weak var reloadIndicatorView: UIActivityIndicatorView? {get set}
    var emptyView: UIView? {get set} //set from XIB or overwrite
    

    /* Load More */
    var supportsLoadMore: Bool {get set}
    var autoLoadMoreContent: Bool {get set}
    var numberOfPagesToPreload: Int {get set}
    var canShowLoadMoreView : Bool {get set}
    func shouldShowLoadMoreForSection(section: Int) -> Bool
    
    var loadMoreViewXIBName: String! {get set}
    
    /* Pull to Refresh functionality */
    weak var refreshControl: UIRefreshControl? {get set}
    func pullToRefreshAction(sender: AnyObject!)
    func addPullToRefresh()
    
    // helpers
    func scrollToContent(content: Any!, animated: Bool)
}


protocol TTCollectionFeedControllerMutable : class {
    var dataSource: TTDataSource? {get set}
    var dataSourceMutable: TTDataSourceMutable? {get}
}

extension TTCollectionFeedControllerMutable {
    var dataSourceMutable: TTDataSourceMutable? {
        return dataSource as? TTDataSourceMutable
    }
}
