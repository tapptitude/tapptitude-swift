//: [Previous](@previous)

import Foundation
import Tapptitude
import XCPlayground
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
    override func awakeFromNib() {
        super.awakeFromNib()
        title = UILabel(frame: CGRect(x: 8, y: 8, width: 334, height: 84))
        self.addSubview(title)
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: title, attribute: .Trailing, multiplier: 1, constant: 8))
        self.addConstraint(NSLayoutConstraint(item: title, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 8))
        self.addConstraint(NSLayoutConstraint(item: title, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 8))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: title, attribute: .Bottom, multiplier: 1, constant: 8))
    }
    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFittingAttributes(layoutAttributes)
        attributes.frame = CGRect(origin: attributes.frame.origin, size: CGSizeMake(200, attributes.frame.height))
        return attributes
    }
    
}


let cellController = CollectionCellController<Text, MyCollectionViewCell>(cellSize: CGSize(width: 350, height: 100))
cellController.configureCell = { (cell: MyCollectionViewCell, content: Text, indexPath: NSIndexPath) -> () in
    cell.title.text = content.title1
}

cellController.setPreferredSizeOfLabels = { (cell: MyCollectionViewCell, laidOutCell: MyCollectionViewCell) -> () in
    cell.title.preferredMaxLayoutWidth = laidOutCell.title.frame.width
}

let feedController = CollectionFeedController()
feedController.cellController = cellController

let collectionView: UICollectionView = UICollectionView(frame: CGRect(origin: CGPointZero, size: CGSizeMake(350, 400)), collectionViewLayout: UICollectionViewFlowLayout())
feedController.view?.frame = CGRect(origin: CGPointZero, size: CGSizeMake(350, 400))
feedController.collectionView = collectionView
feedController.view.addSubview(collectionView)

let layout = feedController.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
layout.estimatedItemSize = CGSizeMake(350, 200)
feedController.collectionView!.backgroundColor = UIColor.whiteColor()


let content: [Any] = [Text("ASDFSD","sdfsdf"), Text("ASDFSD","sdfsdf"), Text("ASDFSD","sdfsdf")]
feedController.dataSource? = DataSource(content)


let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
view.backgroundColor = UIColor.blueColor()

XCPlaygroundPage.currentPage.liveView = view
