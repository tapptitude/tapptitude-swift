//: [Previous](@previous)

import Tapptitude
import PlaygroundSupport
import UIKit


struct Text {
    var title1: String!
    var title2: String!
}

/// because AutolayoutCell is not available in playgrounds we are using UICollectionViewCell extension
extension UICollectionViewCell {
    
    // this should go in your subclass
    override open func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return preferredLayoutAttributesFitting_VerticalResizing(layoutAttributes)
    }
}



class TextCellController: CollectionCellController<Text, UICollectionViewCell> {
    init() {
        super.init(cellSize: CGSize(width: -1, height: 100), reuseIdentifier: "AutolayoutCell")
        minimumLineSpacing = 30
    }
    
    override func configureCell(_ cell: UICollectionViewCell, for content: Text, at indexPath: IndexPath) {
        cell.titleLabel?.text = content.title1
        cell.subtitleLabel?.text = content.title2
    }
    
    override func nibToInstantiateCell(for content: Text) -> UINib? {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
}

let content = [Text(title1: "ASDFSD", title2:"sdfsdf"),
               Text(title1:"Acknowledgements\nWe'd like to thank all of our contributors:", title2:"sdfsdf"),
               Text(title1:"ASDFSD",title2: "For a bot’s integration, committer initials are displayed and enclosed within a white circle. ")]

let feedController = CollectionFeedController()
feedController.dataSource = DataSource(content)
feedController.cellController = TextCellController()

let _ = feedController.view
feedController.useAutoLayoutEstimatedSize = true // activate autolayout adjustemnt based on cell content


feedController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 600)
PlaygroundPage.current.liveView = feedController.view
PlaygroundPage.current.needsIndefiniteExecution = true

    
