//
//  PrefetchFeedController.swift
//  TestTapptitude
//
//  Created by Alexandru Tudose on 17/01/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import Tapptitude
import  UIKit

class PrefetchFeedController: CollectionFeedController {
    override func viewDidLoad() {
        let dataSource = DataSource<String>(loadPage: API.getHackerNews(page:callback:))
        
        self.dataSource = dataSource
        self.cellController = MultiCollectionCellController(TextItemCellController())
    }
}


extension TextItemCellController: CollectionCellPrefetcher {
    
    public func prefetchItems(_ items: [String], at indexPaths: [IndexPath], in collectionView: UICollectionView) {
        print("prefetch", items.first)
    }
    
    public func cancelPrefetchItems(_ items: [String], at indexPaths: [IndexPath], in collectionView: UICollectionView) {
        print("cancelPrefetchItems", items)
    }
}
