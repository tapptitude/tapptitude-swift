//
//  FeedController.swift
//  TestTapptitude
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

class FeedController: CollectionFeedController {
    
    override func viewDidLoad() {
        self.dataSource = DataSource(content: ["arra"])
        let cellController = CollectionCellController<String, UICollectionViewCell>(cellSize: CGSize(width: 50, height: 50))
        cellController.configureCellBlock = { cell, content, indexPath in
            cell.backgroundColor = UIColor.redColor()
            print(cell)
        }
        cellController.didSelectContentBlock = { _, _, _ in
            let controller = CollectionFeedController()
            print(controller.view)
            print(controller.collectionView)
            self.showViewController(controller, sender: nil)
        }
        self.cellController = cellController
        
        super.viewDidLoad()
        
        self.dataSource = DataSource(content: ["arra"])
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.dataSource = nil;
    }
}