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
        return cellSizeToFit(text: content, label: sizeCalculationCell.label)
    }
}



class IntHeaderCellController : CollectionHeaderController<[Int], TextCell> {
    public init() {
        super.init(headerSize: CGSize(width: 30, height: 50))
    }
    
    open override func configureHeader(_ header: TextCell, for content: [Int], at indexPath: IndexPath) {
        header.label.text = content.map({ String($0) }).joined(separator: ", ")
        header.label.textColor = .white
    }
}


class StringHeaderCellController : CollectionHeaderController<[String], TextCell> {
    public init() {
        super.init(headerSize: CGSize(width: 30, height: 80))
    }
    
    open override func configureHeader(_ header: TextCell, for content: [String], at indexPath: IndexPath) {
        header.label.text = content.joined(separator: ", ")
        header.label.textColor = .gray
        header.backgroundColor = .blue
    }
}



class IntCellController : CollectionCellController<Int, TextCell> {
    
    init() {
        super.init(cellSize: CGSize(width: 200, height: 100))
        minimumInteritemSpacing = 20
        minimumLineSpacing = 10
    }
    
    override func configureCell(_ cell: CellType, for content: ContentType, at indexPath: IndexPath) {
        cell.label.text = String(content)
        cell.backgroundColor = UIColor.red
    }
    
    override func cellSize(for content: ContentType, in collectionView: UICollectionView) -> CGSize {
        return cellSizeToFit(text: String(content), label: sizeCalculationCell.label)
    }
}
