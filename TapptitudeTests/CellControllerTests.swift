//
//  CellControllerTests.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 24/04/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import Tapptitude
import UIKit
import XCTest

class CellControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCollectionCellPrefetcher() {
        let prefetcher = PrefetcherCellController()
        let withoutPrefetcher = WithoutPrefetcherCellController()
        XCTAssert(prefetcher.supportsDataSourcePrefetching() == true, "is implementing TTCollectionCellPrefetcher")
        XCTAssert(withoutPrefetcher.supportsDataSourcePrefetching() == false, "is implementing TTCollectionCellPrefetcher")
    }
    
    func testMultiCollectionCellPrefetcher() {
        let prefetcher = MultiCollectionCellController(PrefetcherCellController())
        let withoutPrefetcher = MultiCollectionCellController(WithoutPrefetcherCellController())
        XCTAssert(prefetcher.supportsDataSourcePrefetching() == true, "is implementing TTCollectionCellPrefetcher")
        XCTAssert(withoutPrefetcher.supportsDataSourcePrefetching() == false, "is implementing TTCollectionCellPrefetcher")
        
        let anyPrefetcher = prefetcher as TTAnyCollectionCellController
        let anyWithoutPrefetcher = withoutPrefetcher as TTAnyCollectionCellController
        XCTAssert(anyPrefetcher.supportsDataSourcePrefetching() == true, "is implementing TTCollectionCellPrefetcher")
        XCTAssert(anyWithoutPrefetcher.supportsDataSourcePrefetching() == false, "is implementing TTCollectionCellPrefetcher")
    }
}





class PrefetcherCellController: CollectionCellController<String, UICollectionViewCell> {
    init() {
        super.init(cellSize: CGSize(width: 0, height: 0))
    }
}

class WithoutPrefetcherCellController: CollectionCellController<String, UICollectionViewCell> {
    init() {
        super.init(cellSize: CGSize(width: 0, height: 0))
    }
}


extension PrefetcherCellController: CollectionCellPrefetcher {
    func prefetchItems(_ items: [String], at indexPaths: [IndexPath], in collectionView: UICollectionView) {
        
    }
    
    func cancelPrefetchItems(_ items: [String], at indexPaths: [IndexPath], in collectionView: UICollectionView) {
        
    }
}
