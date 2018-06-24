//
//  ChatFeedViewController.swift
//  TestTapptitude
//
//  Created by Alexandru Tudose on 26/02/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import Tapptitude
import UIKit


class ChatInputContainerView: UIView {
    let maxHeight: CGFloat = 250.0
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.delegate = self
        // Disabling textView scrolling prevents some undesired effects,
        // like incorrect contentOffset when adding new line,
        // and makes the textView behave similar to Apple's Messages app
        textView.isScrollEnabled = false
        
        roundedView.layer.cornerRadius = 2.0
    }
    
    override var intrinsicContentSize: CGSize {
        return containerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
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
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if #available(iOS 11.0, *) {
            if let window = self.window {
                   let constraint = self.containerView.bottomAnchor.constraintLessThanOrEqualToSystemSpacingBelow(window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1)
                constraint.priority = 900
                constraint.isActive = true
            }
        }
    }
}

extension ChatInputContainerView: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        sendButton.isEnabled = !textView.text.isEmpty
        placeholderLabel.isHidden = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty || textView.isFirstResponder
        sendButton.isEnabled = !textView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        textView.isScrollEnabled = textView.contentSize.height > maxHeight
        return true
    }
}


class ChatFeedViewController : __CollectionFeedController {
    @IBOutlet var inputContainerView: ChatInputContainerView!
    var dataSource: DataSource<String>! {
        didSet { _dataSource = dataSource }
    }
    var cellController: MultiCollectionCellController! {
        didSet { _cellController = cellController }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Chat"
        inputContainerView.removeFromSuperview()
        
        let keyboard = self.collectionView?.addKeyboardVisibilityController()
        keyboard?.dismissKeyboardTouchRecognizer = nil
        
        let dataSource = DataSource<String>(loadPage: API.getDummyPage(page:callback:))
//        let dataSource = SectionedDataSource<String>([["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]])
//        let dataSource = SectionedDataSource<String>([[]])
        
        self.cellController = MultiCollectionCellController(TextItemCellController())
        let header = CollectionHeaderController<[String], UICollectionViewCell>(headerSize: CGSize(width: 20, height: 40))
        header.configureHeader = { (header: UICollectionViewCell, content: [String], indexPath) in
            header.backgroundColor = .red
        }
        self.headerController = header
        self.dataSource = dataSource
        animatedUpdates = true
        
        collectionView.contentInset = UIEdgeInsets()
        self.headerIsSticky = true
        self.dataSourceLoadMoreType = .insertAtBeginning
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            dataSource.insert("dasd", at: IndexPath(item: 0, section: 0))
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//            dataSource.remove(at: IndexPath(item: 0, section: 0))
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            dataSource[IndexPath(item: 1, section: 0)] = "maria \n\n"
//        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            dataSource.append(sections: [["13", "14", "15", "16", "17", "18", "19", "20", "21", "22"]])
//        }
    }
    
    @IBAction func sendAction(_ sender: AnyObject) {
        dataSource.append(inputContainerView.text)
        let indexPath = dataSource.lastIndexPath!
        inputContainerView.text = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return inputContainerView
    }
}
