//
//  ActionSheetCellController.swift
//  Tapptitude
//
//  Created by Efraim Budusan on 9/6/16.
//  Copyright © 2016 Efraim Budusan. All rights reserved.
//

import UIKit
import Tapptitude

class ActionSheetCellController: CollectionCellController<TTActionSheetAction, ActionSheetCell> {
    
    init() {
        super.init(cellSize: CGSize(width: -1.0, height: 57.0))
    }
    
    override func cellSize(for content: TTActionSheetAction, in collection: UICollectionView) -> CGSize {
        let cell = sizeCalculationCell
        self.cellConfiguration(cell, forContent: content, indexPath: NSIndexPath(forItem: 0, inSection: 0))
        var size = cell.title.sizeThatFits(CGSizeMake(cell.title.frame.width, 1000))
        size.height += 33
        size.width = cell.frame.width
        return size
    }
    
    override func configureCell(cell: ActionSheetCell, for content: TTActionSheetAction, at indexPath: NSIndexPath!) {
        self.cellConfiguration(cell, forContent: content, indexPath: indexPath)
        cell.content = content
    }
    
    func cellConfiguration(cell: ActionSheetCell, forContent content: TTActionSheetAction, indexPath: NSIndexPath!) {
        cell.title.text = content.title
    }
    
    override func didSelectContent(content: TTActionSheetAction, at indexPath: NSIndexPath, in collectionView: UICollectionView) {
        
    }
}
