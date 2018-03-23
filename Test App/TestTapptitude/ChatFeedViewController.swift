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
    let maxTextviewHeight: CGFloat = 90.0
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textViewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textViewContainer.layer.borderWidth = 0.5
        textViewContainer.layer.borderColor = UIColor.gray.withAlphaComponent(0.6).cgColor
        textViewContainer.layer.cornerRadius = 2.0
        placeholderLabel.text = "Scrie un mesaj aici..."
        self.autoresizingMask = [.flexibleHeight] // mandatory to have textView autoresize
    }
    
    // taken from http://stackoverflow.com/questions/25816994/changing-the-frame-of-an-inputaccessoryview-in-ios-8
    override var intrinsicContentSize: CGSize {
        let size = self.textView.sizeThatFits(CGSize(width: self.textView.frame.size.width, height: self.maxTextviewHeight))
        let heightDiff = ceil(self.textView.frame.size.height - size.height)
        
        var desiredSize = bounds.size
        if fabs(heightDiff) > 1 && (self.textView.contentSize.height < self.maxTextviewHeight || heightDiff > 0) {
            let inputContainerFrame = UIEdgeInsetsInsetRect(self.frame, UIEdgeInsetsMake(heightDiff, 0, 0, 0))
            desiredSize.height = inputContainerFrame.height
        }
        
        return desiredSize
    }
    
    func clearTextViewText() {
        self.text = ""
    }
    
    var text: String {
        get { return textView.text ?? "" }
        set {
            self.textView.text = newValue
            self.placeholderLabel.isHidden = !newValue.isEmpty
            self.sendButton.isEnabled = !newValue.isEmpty
            self.invalidateIntrinsicContentSize()
        }
    }
    
    /* thist throws a constraint warning
     This is clearly an Apple bug. My guess is that they have an errant constraint that holds the status bars height at 20 px but is broken when the call bar grows. This doesn't break or affect the app so it can safely be ignored for now. But an Apple Radar should be filled.
     */
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        // enable only for iPhoneX
        let SCREEN_MAX_LENGTH = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.width)
        let IS_IPHONE_X = UIDevice.current.userInterfaceIdiom == .phone && SCREEN_MAX_LENGTH == 812.0
        guard IS_IPHONE_X else {
            return
        }
        
        if #available(iOS 11.0, *) {
            if let window = self.window {
                self.bottomAnchor.constraintLessThanOrEqualToSystemSpacingBelow(window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1).isActive = true
                self.textViewContainer.bottomAnchor.constraintLessThanOrEqualToSystemSpacingBelow(self.bottomAnchor, multiplier: 0.75).isActive = true
            }
        }
    }
}

extension ChatInputContainerView: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        self.placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.sendButton.isEnabled = !textView.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.placeholderLabel.isHidden = !textView.text.isEmpty
        self.sendButton.isEnabled = !textView.text.isEmpty
        
        self.invalidateIntrinsicContentSize()
        self.textView.isScrollEnabled = self.textView.bounds.height >= maxTextviewHeight
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
        
        
        
//        self.edgesForExtendedLayout = []
        
        animatedUpdates = true
        
        collectionView.contentInset = .zero
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
        dataSource.append(self.inputContainerView.text)
        let indexPath = dataSource.lastIndexPath!
        self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        self.inputContainerView.text = ""
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return self.inputContainerView
    }
}
