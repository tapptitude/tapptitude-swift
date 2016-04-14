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
        addSubview(label)
        
        backgroundColor = UIColor(white: 0, alpha: 0.3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

let items = ["Test", "Ghita", "Maria", "Collection", "Cell", "Controller"]
print(items)
print(items.groupBy({ $0.characters.first!.debugDescription }))

let dataSource = SectionedDataSource([["Test", "Ghita"], ["Maria"], ["Collection", "Cell", "Controller"]])
let cellController = CollectionCellController<String, TextCell>(cellSize: CGSize(width: 50, height: 50))
cellController.sectionInset = UIEdgeInsetsMake(0, 0, 10, 0)
cellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = UIColor.redColor()
    cell.label.text = content
}

let feedController = CollectionFeedController()
feedController.dataSource = dataSource
feedController.cellController = cellController

print(dataSource.content)
let testDataSource = SectionedDataSource(NSArray(array: [["Test"]]))

import XCPlayground
XCPlaygroundPage.currentPage.liveView = feedController.view
//: [Next](@next)
