//
//  DataSourceTests.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 28/01/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import XCTest
import Tapptitude

class DataSourceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testDataSource() {
        let content = ["1", "2", "3"]
        
        let dataSource = DataSource(content)
        XCTAssert(dataSource.numberOfSections() == 1, "Expected 1 section")
        XCTAssert(dataSource.numberOfItems(inSection: 0) == content.count, "Invalid nr of items in section 0")
        XCTAssert(dataSource[0] == content[0], "Different element found")
        XCTAssert(dataSource[0, 0] == content[0], "Different element found")
        XCTAssert(dataSource[IndexPath(item:0, section:0)] == content[0], "Different element found")
        XCTAssert(dataSource.indexPath(ofFirst: {$0 == content[1]}) == IndexPath(item:1, section:0), "Different element found")
        
        let appendItem = "4"
        dataSource.append(appendItem)
        XCTAssert(dataSource[dataSource.count - 1] == appendItem, "append not working")
        
        let appendItems = ["5", "6"]
        dataSource.append(contentsOf: appendItems)
        XCTAssert(dataSource[dataSource.count - 2] == appendItems[0], "append(contentsOf: not working")
        XCTAssert(dataSource[dataSource.count - 1] == appendItems[1], "append(contentsOf: not working")
        

        var insertItem = "7"
        dataSource.insert(insertItem, at: IndexPath(item: 0, section: 0))
        XCTAssert(dataSource[0] == insertItem, "insert not working")
        
        insertItem = "8"
        dataSource.insert(insertItem, at: IndexPath(item: dataSource.count, section: 0))
        XCTAssert(dataSource[dataSource.count - 1] == insertItem, "insert not working")
        
        insertItem = "9"
        dataSource.insert(insertItem, at: IndexPath(item: dataSource.count - 1, section: 0))
        XCTAssert(dataSource[dataSource.count - 2] == insertItem, "insert not working")
        
        
        let insertItems = ["10", "11"]
        dataSource.insert(contentsOf: insertItems, at: IndexPath(item: dataSource.count - 1, section: 0))
        XCTAssert(dataSource[dataSource.count - 3] == insertItems[0], "insert(contentsOf not working")
        XCTAssert(dataSource[dataSource.count - 2] == insertItems[1], "insert(contentsOf not working")
        
        
        dataSource.remove{$0 == appendItem}
        XCTAssert(dataSource.index(of: appendItem) == nil, "remove not working")
        
        let fromIndexPath = IndexPath(item:1, section:0)
        let toIndexPath = IndexPath(item:0, section:0)
        let fromItem: String = dataSource[fromIndexPath]
        let toItem: String = dataSource[toIndexPath]
        XCTAssert(fromItem != toItem, "should be different")
        dataSource.moveElement(from:fromIndexPath, to: toIndexPath)
        XCTAssert(dataSource[fromIndexPath] == toItem, "should be different")
        XCTAssert(dataSource[toIndexPath] == fromItem, "should be different")
        
        
        let removeIndexPath = IndexPath(item:1, section:0)
        let removedItem: String = dataSource[removeIndexPath]
        dataSource.remove(at: removeIndexPath)
        XCTAssert(dataSource[removeIndexPath] != removedItem, "remove(at: not working")
        
        let removeIndexPath1 = IndexPath(item:1, section:0)
        let removeIndexPath2 = IndexPath(item:2, section:0)
        let removedItem1: String = dataSource[removeIndexPath1]
        let removedItem2: String = dataSource[removeIndexPath2]
        dataSource.remove(at: [removeIndexPath2, removeIndexPath1])
        XCTAssert(dataSource[removeIndexPath1] != removedItem1, "remove(at: not working")
        XCTAssert(dataSource[removeIndexPath2] != removedItem2, "remove(at: not working")
    }
    
    
    func testSectionedDataSource() {
        let content = [[], ["1", "2", "3"]]
        
        let dataSource = SectionedDataSource(content)
        XCTAssert(dataSource.numberOfSections() == 2, "Expected 1 section")
        XCTAssert(dataSource.numberOfItems(inSection: 0) == content[0].count, "Invalid nr of items in section 0")
        XCTAssert(dataSource.numberOfItems(inSection: 1) == content[1].count, "Invalid nr of items in section 0")
        XCTAssert(dataSource[1] == content[1], "Different element found")
        XCTAssert(dataSource[1, 0] == content[1][0], "Different element found")
        XCTAssert(dataSource[IndexPath(item:1, section:1)] == content[1][1], "Different element found")
        XCTAssert(dataSource.indexPath(ofFirst: {$0 == content[1][1]}) == IndexPath(item:1, section:1), "Different element found")
        
        let appendItem = ["4"]
        dataSource.append(sections: [appendItem])
        XCTAssert(dataSource[dataSource.count - 1] == appendItem, "append not working")
        
        
        var insertItem = "7"
        dataSource.insert(insertItem, at: IndexPath(item: 1, section: 1))
        XCTAssert(dataSource[1, 1] == insertItem, "insert not working")
        
        insertItem = "8"
        dataSource.insert(insertItem, at: IndexPath(item: dataSource[1].count, section: 1))
        XCTAssert(dataSource[1, dataSource[1].count - 1] == insertItem, "insert not working")
        
        insertItem = "9"
        dataSource.insert(insertItem, at: IndexPath(item: dataSource[1].count - 1, section: 1))
        XCTAssert(dataSource[1, dataSource[1].count - 2] == insertItem, "insert not working")
        
        
        let insertItems = ["10", "11"]
        dataSource.insert(contentsOf: insertItems, at: IndexPath(item: dataSource[1].count - 1, section: 1))
        XCTAssert(dataSource[1, dataSource[1].count - 3] == insertItems[0], "insert(contentsOf not working")
        XCTAssert(dataSource[1, dataSource[1].count - 2] == insertItems[1], "insert(contentsOf not working")
        
        
        let item = "1"
        dataSource.remove{$0 == item}
        XCTAssert(dataSource.indexPath(ofFirst: { $0 == item }) == nil, "remove not working")
        
        let fromIndexPath = IndexPath(item:1, section:1)
        let toIndexPath = IndexPath(item:0, section:0)
        let fromItem: String = dataSource[fromIndexPath]
        let nextItem: String = dataSource[IndexPath(item:2, section:1)]
        XCTAssert(fromItem != nextItem, "should be different")
        dataSource.moveElement(from:fromIndexPath, to: toIndexPath)
        XCTAssert(dataSource[fromIndexPath] == nextItem, "should be different")
        XCTAssert(dataSource[toIndexPath] == fromItem, "should be different")
        
        
        let removeIndexPath = IndexPath(item:1, section:1)
        let removedItem: String = dataSource[removeIndexPath]
        dataSource.remove(at: removeIndexPath)
        XCTAssert(dataSource[removeIndexPath] != removedItem, "remove(at: not working")
        
        let removeIndexPath1 = IndexPath(item:1, section:1)
        let removeIndexPath2 = IndexPath(item:2, section:1)
        let removedItem1: String = dataSource[removeIndexPath1]
        let removedItem2: String = dataSource[removeIndexPath2]
        dataSource.remove(at: [removeIndexPath2, removeIndexPath1])
        XCTAssert(dataSource[removeIndexPath1] != removedItem1, "remove(at: not working")
        XCTAssert(dataSource[removeIndexPath2] != removedItem2, "remove(at: not working")
    }
    
}
