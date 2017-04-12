//
//  File.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 07/04/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import UIKit

public protocol TTLoadMoreController {
    var collectionView: UICollectionView? {get set}
    var loadMorePosition: LoadMoreController.Position {get set}
    var autoLoadMoreContent: Bool {get set}
    var numberOfPagesToPreload: CGFloat {get set} // load more content when last 2 pages are visible
    var canShowLoadMoreView : Bool {get set}
    
    func updateCanShowLoadMoreView(for feed: TTDataFeed?,  animated: Bool)
    func checkIfShouldLoadMoreContent(for feed: TTDataFeed?)
    func updateLoadMoreViewPosition(in collectionView: UICollectionView)
    
    // based on different capabilites
    func sizeForLoadMoreViewInSection(_ section: Int, collectionView: UICollectionView) -> CGSize
    func loadMoreView(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionReusableView?
    func adjustSectionInsetToShowLoadMoreView(sectionInset: UIEdgeInsets, collectionView: UICollectionView, section: Int) -> UIEdgeInsets
}
