//
//  TableFeedController.swift
//  TestTapptitude
//
//  Created by Alexandru Tudose on 14/11/2018.
//  Copyright © 2018 Tapptitude. All rights reserved.
//

import UIKit
import Tapptitude

class TestTableViewController : __TableFeedController {
    
    lazy var dataSource = DataSource<String>(loadPage: APIPaginateOffsetdSwiftMock.getResults(offset:callback:))
    //  lazy var dataSource = DataSource(Example.allTest())
    var collectionController = CollectionFeedController()
    var forceTouchPreview: ForceTouchPreview!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self._cellController = TextTableCellController()
        self._dataSource = dataSource
        
        addPullToRefresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
