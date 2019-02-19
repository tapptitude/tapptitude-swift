import UIKit

/*
 Custom input accesory view example useful for a chat view
 */

public class ChatInputContainerView: UIView {
    let maxHeight: CGFloat = 250.0
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.delegate = self
        // Disabling textView scrolling prevents some undesired effects,
        // like incorrect contentOffset when adding new line,
        // and makes the textView behave similar to Apple's Messages app
        textView.isScrollEnabled = false
        
        roundedView.layer.cornerRadius = 2.0
    }
    
    public override var intrinsicContentSize: CGSize {
        return containerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    var text: String {
        get { return textView.text ?? "" }
        set {
            textView.isScrollEnabled = false
            textView.text = newValue
            placeholderLabel.isHidden = !newValue.isEmpty || textView.isFirstResponder
            sendButton.isEnabled = !newValue.isEmpty
            textView.isScrollEnabled = textView.contentSize.height > maxHeight
        }
    }
    
    // containerView - bottom priority to it's superview should be 750
    // fix for iphone x
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if #available(iOS 11.0, *) {
            if let window = self.window {
                let constraint = self.containerView.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1)
                constraint.priority = UILayoutPriority(rawValue: 900)
                constraint.isActive = true
            }
        }
    }
}


extension ChatInputContainerView: UITextViewDelegate {
    public func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        sendButton.isEnabled = !textView.text.isEmpty
        placeholderLabel.isHidden = true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty || textView.isFirstResponder
        sendButton.isEnabled = !textView.text.isEmpty
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        textView.isScrollEnabled = textView.contentSize.height > maxHeight
        return true
    }
}
