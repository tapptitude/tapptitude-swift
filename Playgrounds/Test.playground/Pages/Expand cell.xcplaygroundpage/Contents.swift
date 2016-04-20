//: [Previous](@previous)

import UIKit
import Tapptitude

class TextCell : UICollectionViewCell {
    var label: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label = UILabel(frame: bounds)
        label.textColor = UIColor.blackColor()
        label.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        label.textAlignment = .Center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.frame = self.bounds
        contentView.autoresizesSubviews = true
        contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        contentView.addSubview(label)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let rectView = UIView(frame: CGRect(x: 10, y: 10, width: 10, height: 10))
        rectView.backgroundColor = UIColor.redColor()
        rectView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        contentView.addSubview(rectView)
        
        backgroundColor = UIColor(white: 0, alpha: 0.3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


let dataSource = DataSource([50, 50, 50, 50])
let cellController = CollectionCellController<Int, TextCell>(cellSize: CGSize(width: 50, height: 50))
cellController.minimumLineSpacing = 5
cellController.minimumInteritemSpacing = 5

let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = cellController
feedController.collectionView?.backgroundColor = UIColor.whiteColor()
//feedController.animatedUpdates = true

cellController.cellSizeForContent = { content, collectionView in
    return CGSize(width: content, height: content)
}
cellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = UIColor.redColor()
    cell.contentView.backgroundColor = UIColor.blueColor()
    cell.label.text = "\(content)"
    print("configure ", content)
}
cellController.didSelectContent = { content, indexPath, collectionView in
    print("did select", content)
    let datasource = dataSource as? TTDataSourceMutable
    collectionView .performBatchUpdates({
        let newContent = content < 150 ? content + 30 : content - 30
        dataSource[indexPath] = newContent
        }, completion: nil)
    
}

import XCPlayground
XCPlaygroundPage.currentPage.liveView = feedController.view

//: [Next](@next)
