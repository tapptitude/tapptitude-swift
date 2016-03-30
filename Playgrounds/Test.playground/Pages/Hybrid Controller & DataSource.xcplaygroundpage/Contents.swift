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
        contentView.addSubview(label)
        
        backgroundColor = UIColor(white: 0, alpha: 0.3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// 1 cell controller --------
let stringCellController = CollectionCellController<String, TextCell>(cellSize: CGSize(width: 50, height: 50))
stringCellController.minimumInteritemSpacing = 20
stringCellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = UIColor.redColor()
    cell.label.text = content
}
stringCellController.didSelectContent = { content, indexPath, collectionView in
    print("did select", content)
}

// 2 cell controller --------
let grayCellController = CollectionCellController<String, TextCell>(cellSize: CGSize(width: 50, height: 70))
grayCellController.minimumInteritemSpacing = 20
grayCellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = UIColor.grayColor()
    cell.label.textColor = UIColor.whiteColor()
    cell.label.text = content
}
grayCellController.didSelectContent = { content, indexPath, collectionView in
    print("did select", content)
}

// 3 cell controller --------
let numberCellController = CollectionCellController<Int, UICollectionViewCell>(cellSize: CGSize(width: 100, height: 50))
numberCellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = UIColor.blueColor()
}
numberCellController.didSelectContent = { content, indexPath, collectionView in
    print("did select", content)
}


// datasource
let dataSource = DataSource(["Maria", "232", 23])
let multiCellController = HybridCellController([stringCellController, numberCellController, grayCellController])

let feedController = CollectionFeedController()
feedController.dataSource = HybridDataSource(content: ["Maria", "232", 23], multiCellController: multiCellController)
feedController.cellController = multiCellController

import XCPlayground
XCPlaygroundPage.currentPage.liveView = feedController.view

//: [Next](@next)
