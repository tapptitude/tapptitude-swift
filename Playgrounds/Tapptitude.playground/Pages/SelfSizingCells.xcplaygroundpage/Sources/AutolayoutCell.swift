import UIKit
import Tapptitude

public extension UICollectionViewCell {
    enum Labels: String {
        case titleLabel
        case subtitleLabel
    }
    
    @IBOutlet var titleLabel: UILabel? {
        get {
            return layer.value(forKey: Labels.titleLabel.rawValue) as? UILabel
        }
        set {
            print("set titleLabel")
            layer.setValue(newValue, forKey: Labels.titleLabel.rawValue)
        }
    }
    
    @IBOutlet var subtitleLabel: UILabel? {
        get {
            return layer.value(forKey: Labels.subtitleLabel.rawValue) as? UILabel
        }
        set {
            print("set subtitleLabel")
            layer.setValue(newValue, forKey: Labels.subtitleLabel.rawValue)
        }
    }
}

//public class AutolayoutCell: UICollectionViewCell {
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var subtitleLabel: UILabel?
//    
//    override public func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        return preferredLayoutAttributesFitting_VerticalResizing(layoutAttributes)
//    }
//}
