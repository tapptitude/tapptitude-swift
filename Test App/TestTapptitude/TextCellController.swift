//
//  TextCellController.swift
//  TestTapptitude
//
//  Created by Alexandru Tudose on 23/03/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit
import Tapptitude

class TextCellController : CollectionCellController<String, TextCell> {
    
    init() {
        super.init(cellSize: CGSize(width: 200, height: 100))
        minimumInteritemSpacing = 20
        minimumLineSpacing = 10
    }
    
    override func configureCell(_ cell: CellType, for content: ContentType, at indexPath: IndexPath) {
        cell.label.text = content
        cell.backgroundColor = UIColor.red
    }
    
    override func cellSize(for content: ContentType, in collectionView: UICollectionView) -> CGSize {
        return self.cellSizeToFit(text: content, labelName: "label")
    }
}
