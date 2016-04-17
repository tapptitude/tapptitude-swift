import UIKit

public class TextCell : UICollectionViewCell {
    public var label: UILabel!
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        label = UILabel(frame: bounds)
        label.textColor = UIColor.blackColor()
        label.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        label.textAlignment = .Center
        addSubview(label)
        
        backgroundColor = UIColor(white: 0, alpha: 0.3)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}