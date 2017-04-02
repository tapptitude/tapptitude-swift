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


class ChatFeedViewController : CollectionFeedController {
    @IBOutlet var inputContainerView: ChatInputContainerView!
    var _dataSource: DataSource<String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Chat"
        inputContainerView.removeFromSuperview()
        
        let keyboard = self.collectionView?.addKeyboardVisibilityController()
        keyboard?.dismissKeyboardTouchRecognizer = nil
        
        let dataSource = DataSource<String>(loadPage: API.getHackerNews(page:callback:))
//        let dataSource = DataSource<String>()
        self.dataSource = dataSource
        self._dataSource = dataSource
        self.cellController = MultiCollectionCellController(TextItemCellController())
        self.loadMoreController?.loadMorePosition = .bottom
        
        self.collectionView.register(LoadMoreView.self, forSupplementaryViewOfKind: "test", withReuseIdentifier: "LoadMoreView")
        
        self.edgesForExtendedLayout = []
        
        animatedUpdates = true
        self.isReversed = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { 
//            dataSource.insert("dasd", at: IndexPath(item: 0, section: 0))
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//            dataSource.remove(at: IndexPath(item: 1, section: 0))
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            dataSource[IndexPath(item: 1, section: 0)] = "maria \n\n"
//        }
    }
    
    @IBAction func sendAction(_ sender: AnyObject) {
        let indexPath = IndexPath(item: 0, section: 0)
        _dataSource.insert(self.inputContainerView.text, at: indexPath)
        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        self.inputContainerView.text = ""
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return self.inputContainerView
    }
}

