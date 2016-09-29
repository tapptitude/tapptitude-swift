//
//  ImagesFullScreenCellController.swift
//  Bildnytt
//
//  Created by Ion Toderasco on 01/08/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit
import Tapptitude

class ImagesFullScreenCellController: CollectionCellController<ImageResource, ImagesFullScreenCell> {
    
    init() {
        super.init(cellSize: CGSize(width: -1.0, height: -1.0))
        self.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10)
        self.minimumLineSpacing = 20
    }
    
    override func cellSize(for content: ImageResource,in collectionView: UICollectionView) -> CGSize {
        var size = collectionView.bounds.size
        size.width -= 20
        
        return size
    }
    
    override func configureCell(cell: ImagesFullScreenCell, for content: ImageResource, at indexPath: NSIndexPath!) {
        cell.updateMinimumZoomScale()
        cell.updateConstraintsForSize(cell.bounds.size)
        cell.scrollView.zoomScale = cell.scrollView.minimumZoomScale
        cell.imageView.image = content.image

    }
    
    override func didSelectContent(content: ImageResource, at indexPath: NSIndexPath, in collectionView: UICollectionView) {
    }
}
