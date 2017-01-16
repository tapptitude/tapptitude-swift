import UIKit
import Tapptitude

class AutolayoutCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel?
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        if #available(iOS 9.0, *) {
            return preferredLayoutAttributesFitting_VerticalResizing(layoutAttributes)
        } else {
            return layoutAttributes
        }
    }
}
