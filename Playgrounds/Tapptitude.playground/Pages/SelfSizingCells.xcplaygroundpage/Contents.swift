//: [Previous](@previous)

import Foundation
import Tapptitude
import PlaygroundSupport
import UIKit


class Text {
    var title1: String!
    var title2: String!
    init( _ title1:String, _ title2:String) {
        self.title1 = title1
        self.title2 = title2
    }
}


class MyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak  var title: UILabel!
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let title = UILabel(frame: CGRect(x: 8, y: 8, width: frame.width, height: 84))
        self.addSubview(title)
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: title, attribute: .trailing, multiplier: 1, constant: 8))
        self.addConstraint(NSLayoutConstraint(item: title, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 8))
        self.addConstraint(NSLayoutConstraint(item: title, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 8))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: title, attribute: .bottom, multiplier: 1, constant: 8))
        self.title = title
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        attributes.frame = CGRect(origin: attributes.frame.origin, size: CGSize(width:200, height:attributes.frame.height))
        return attributes
    }
    
}


let cellController = CollectionCellController<Text, MyCollectionViewCell>(cellSize: CGSize(width: -1, height: 100))
cellController.configureCell = { (cell: MyCollectionViewCell, content: Text, indexPath: IndexPath) -> () in
    cell.title.text = content.title1
}

cellController.setPreferredSizeOfLabels = { (cell: MyCollectionViewCell, laidOutCell: MyCollectionViewCell) -> () in
    cell.title.preferredMaxLayoutWidth = laidOutCell.title.frame.width
}

let feedController = CollectionFeedController()
let content: [Any] = [Text("ASDFSD","sdfsdf"), Text("ASDFSD","sdfsdf"), Text("ASDFSD","sdfsdf")]
feedController.dataSource = DataSource(content)
feedController.cellController = cellController

let _ = feedController.view


let layout = feedController.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
layout.estimatedItemSize = CGSize(width:350, height:200)

import PlaygroundSupport
PlaygroundPage.current.liveView = feedController.view
PlaygroundPage.current.needsIndefiniteExecution = true

    
