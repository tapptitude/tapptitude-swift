//
//  ChatCollectionFeedController.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 01/04/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import UIKit

class ChatCollectionFeedController: CollectionFeedController {
    @IBOutlet var loadMoreView: UIActivityIndicatorView!
    
    func addTopLoadMoreView() {
        let topInset = loadMoreView.bounds.height
        loadMoreView.frame.origin.y = -topInset
        loadMoreView.center = CGPoint(x: collectionView!.bounds.midX, y: -loadMoreView.bounds.midY)
        collectionView?.addSubview(loadMoreView)
    }
    
//    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return .zero
//    }
    
    
//    open override func shouldShowLoadMore(section: Int) -> Bool { // default - YES only for last section
//        return (dataSource != nil && (section == dataSource!.numberOfSections() - 1))
//    }
}
