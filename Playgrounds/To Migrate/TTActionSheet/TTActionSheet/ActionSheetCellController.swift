//
//  ActionSheetCellController.swift
//  Tapptitude
//
//  Created by Efraim Budusan on 9/6/16.
//  Copyright © 2016 Efraim Budusan. All rights reserved.
//

import UIKit
import Tapptitude

class ActionSheetCellController<Content:TTActionSheetActionProtocol,Cell:ActionSheetCell> : CollectionCellController<Content, Cell> {
    
    init() {
        super.init(cellSize: CGSize(width: -1.0, height: 57.0))
    }
    
    init(cellSize:CGSize) {
        super.init(cellSize: cellSize)
    }
    
    
    override func cellSize(for content: Content, in collection: UICollectionView) -> CGSize {
        let cell = sizeCalculationCell
        self.cellConfiguration(cell: cell!, forContent: content, indexPath: NSIndexPath(item: 0, section: 0))
        var size = cell?.title.sizeThatFits(CGSize(width:(cell?.title.frame.width)!,height:1000))
        size?.height += 33
        size?.width = (cell?.frame.width)!
        return size!
    }
    
    override func configureCell(_ cell: Cell, for content: Content, at indexPath: IndexPath) {
        cell.content = content as TTActionSheetActionProtocol
        cell.title.text = content.title
    }
    
    func cellConfiguration(cell: Cell, forContent content: Content, indexPath: NSIndexPath!) {
        cell.title.text = content.title
    }
    
    override func didSelectContent(_ content: Content, at indexPath: IndexPath, in collectionView: UICollectionView) {
        
    }
}
