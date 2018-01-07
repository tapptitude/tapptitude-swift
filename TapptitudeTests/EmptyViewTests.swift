//
//  EmptyViewTests.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 16/05/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import XCTest
import Tapptitude

class EmptyViewTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEmptyView() {
        let controller = CollectionFeedController()
        controller.cellController = TestCellController()
        let _ = controller.view
        XCTAssert(controller.emptyView != nil, "dataSource == nil --> emptyView should be !nil")
        XCTAssert(controller.emptyView?.isHidden == true, "dataSource == nil --> emptyView should be hidden")
        
        controller.dataSource = DataSource([])
        XCTAssert(controller.emptyView?.isHidden == false, "dataSource empty --> emptyView should be !hidden")
        
        let dataSource = DataSource(["12"])
        controller.dataSource = dataSource
        XCTAssert(controller.emptyView?.isHidden == true, "dataSource !empty --> emptyView should be hidden")
        
        XCTAssert(controller.collectionView.numberOfItems(inSection: 0) == 1, "dataSource !empty --> single item")
        dataSource.remove { (item) -> Bool in
            return true
        }
        XCTAssert(controller.emptyView?.isHidden == false, "dataSource empty --> emptyView should be !hidden")
        
        XCTAssert(controller.collectionView.numberOfItems(inSection: 0) == 0, "dataSource empty")
        dataSource.append("12")
        XCTAssert(controller.collectionView.numberOfItems(inSection: 0) == 1, "dataSource !empty --> single item")
        
        let asyncExpectation = expectation(description: "longRunningFunction")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dataSource.append("12")
            XCTAssert(controller.collectionView.numberOfItems(inSection: 0) == 2, "dataSource !empty --> single item")
            XCTAssert(controller.emptyView?.isHidden == true, "dataSource !empty --> emptyView should be hidden")
            asyncExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 0.11) { (error) in
        }
    }
    
    func testEmptyViewReloadHasContent() {
        let controller = CollectionFeedController()
        controller.cellController = TestCellController()
        let dataSource = DataSource<String>([])
        controller.dataSource = dataSource
        
        let feedTests = DataFeedTests()
        let feed = feedTests.feedDelayed
        dataSource.feed = feed
        feed.reload()
        
        let asyncExpectation = expectation(description: "longRunningFunction")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            XCTAssert(controller.emptyView?.isHidden == true, "feed is loading --> emptyView should be hidden")
            asyncExpectation.fulfill()
        }
        
        let secondAsyncExpectation = expectation(description: "longRunningFunction")
        DispatchQueue.main.asyncAfter(deadline: .now() + DataFeedTests.delay + 0.0001) {
            XCTAssert(controller.emptyView?.isHidden == true, "feed is not loading has content --> emptyView should be hidden")
            secondAsyncExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout:  DataFeedTests.delay + 0.001) { (error) in
        }
    }
    
    func testEmptyViewFeedLoadingNotContent() {
        let controller = CollectionFeedController()
        controller.cellController = TestCellController()
        
        
        controller.dataSource = DataSource([])
        XCTAssert(controller.emptyView?.isHidden == false, "dataSource empty --> emptyView should be !hidden")
        
        let dataSource = DataSource<String>(feed: feedDelayedError)
        controller.dataSource = dataSource
        XCTAssert(controller.emptyView?.isHidden == true, "feed is loading --> emptyView should be hidden")
        
        let asyncExpectation = expectation(description: "longRunningFunction")
        DispatchQueue.main.asyncAfter(deadline: .now() + DataFeedTests.delay + 0.0001) {
            XCTAssert(controller.emptyView?.isHidden == false, "feed is not loading && has no content --> emptyView should be !hidden")
            asyncExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: DataFeedTests.delay + 0.0001) { (error) in
        }
    }
    
    
    var feedDelayedError: SimpleFeed<String> {
        return SimpleFeed<String>(load: { callback in
            let api = APIMock()
            api.content = nil
            api.error = NSError(domain: "dummy error", code: 1, userInfo: nil)
            api.callback = callback
            api.delay = DataFeedTests.delay
            api.run()
            return api
        })
    }
}

class TestCellController: CollectionCellController<String, UICollectionViewCell> {
    init() {
        super.init(cellSize: CGSize(width: 0, height: 0))
    }
}
