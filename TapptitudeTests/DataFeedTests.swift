//
//  DataFeedTests.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 28/01/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import XCTest
import Tapptitude

class DataFeedTests: XCTestCase {
    static let delay = 0.0001
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    var mockSimpleAPI: APIMock {
        let api = APIMock()
        api.content = ["1", "2", "3"]
        api.delay = 0
        return api
    }
    
    func testSimpleDataFeedLoadDataImediatly() {
        let feed = SimpleDataFeed<String>(load: { callback in
            let api = self.mockSimpleAPI
            api.callback = callback
            api.run()
            return api
        })
        let dataSource = DataSource<String>(feed: feed)
        
        XCTAssert(dataSource.isEmpty)
        dataSource.feed?.reload()
        XCTAssert(dataSource.isEmpty == false)
        
        XCTAssert(dataSource.content.map({$0 as! String}) == mockSimpleAPI.content!)
    }
    
    var feedDelayed: SimpleDataFeed<String> {
        return SimpleDataFeed<String>(load: { callback in
            let api = self.mockSimpleAPI
            api.callback = callback
            api.delay = DataFeedTests.delay
            api.run()
            return api
        })
    }
    
    func testSimpleDataFeedDelayed() {
        let dataSource = DataSource<String>(feed: feedDelayed)
        
        XCTAssert(dataSource.isEmpty)
        dataSource.feed?.reload()
        XCTAssert(dataSource.isEmpty)
        
        let asyncExpectation = expectation(description: "longRunningFunction")
        DispatchQueue.main.asyncAfter(deadline: .now() + DataFeedTests.delay + 0.0001) {
            XCTAssert(dataSource.isEmpty == false)
            XCTAssert(dataSource.content.map({$0 as! String}) == self.mockSimpleAPI.content!)
            asyncExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: DataFeedTests.delay + 0.0001) { (error) in
        }
    }

    func testSimpleDataFeedCancelled() {
        let dataSource = DataSource<String>(feed: feedDelayed)
        
        XCTAssert(dataSource.isEmpty)
        dataSource.feed?.reload()
        dataSource.feed?.cancelReload()
        XCTAssert(dataSource.isEmpty)
        
        let asyncExpectation = expectation(description: "longRunningFunction")
        DispatchQueue.main.asyncAfter(deadline: .now() + DataFeedTests.delay + 0.0001) {
            XCTAssert(dataSource.isEmpty == true)
            asyncExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: DataFeedTests.delay + 0.0001) { (error) in
        }
    }
    
    var feedIgnoringCancel: SimpleDataFeed<String> {
        return SimpleDataFeed<String>(load: { callback in
            let api = self.mockSimpleAPI
            DispatchQueue.main.asyncAfter(deadline: .now() + DataFeedTests.delay) {
                callback(api.content, api.error)
            }
            return api
        })
    }
    
    func testSimpleDataFeedCancelledIgnoreCancel() {
        let dataSource = DataSource<String>(feed: feedIgnoringCancel)
        
        XCTAssert(dataSource.isEmpty)
        dataSource.feed?.reload()
        dataSource.feed?.cancelReload()
        XCTAssert(dataSource.isEmpty)
        
        let asyncExpectation = expectation(description: "longRunningFunction")
        DispatchQueue.main.asyncAfter(deadline: .now() + DataFeedTests.delay + 0.0001) {
            XCTAssert(dataSource.isEmpty == true)
            asyncExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: DataFeedTests.delay + 0.0001) { (error) in
        }
    }
    
    func testSimpleDataFeedDealloc() {
        let delay = 0.0001
        var feed: SimpleDataFeed<String>? = feedIgnoringCancel
        let dataSource = DataSource<String>(feed: feed!)
        feed = nil
        
        XCTAssert(dataSource.isEmpty)
        dataSource.feed?.reload()
        dataSource.feed = nil
        XCTAssert(dataSource.isEmpty)
        
        let asyncExpectation = expectation(description: "longRunningFunction")
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.0001) {
            XCTAssert(dataSource.isEmpty == true)
            asyncExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: delay + 0.0001) { (error) in
        }
    }
    
    func testPaginatedDataFeed() {
        
    }
    
    func testParallelDataFeed() {
        
    }
}
