import UIKit

open class TextCell : UICollectionViewCell {
    open var label: UILabel!
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        label = UILabel(frame: bounds)
        label.textColor = UIColor.black
        label.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        addSubview(label)
        
        backgroundColor = UIColor(white: 0, alpha: 0.3)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
