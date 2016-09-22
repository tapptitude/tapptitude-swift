//
//  TTActionSheet.swift
//  Tapptitude
//
//  Created by Efraim Budusan on 9/6/16.
//  Copyright © 2016 Efraim Budusan. All rights reserved.
//

import UIKit
import Tapptitude


class MyViewController: CollectionFeedController {
        

public class TTActionSheet: CollectionFeedController {

    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var maskViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var topCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var sheetTitleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var blurBgView: UIVisualEffectView!
    
    var sheetTitle:String? = nil
    var message: String? = nil
    var cancelMessage: String? = nil
    var actions: [TTActionSheetAction] = []
    private var headerIsVisible: Bool = true
    
    let transtionController = DimmingTransition()
    
    public init(title:String? = nil, message:String? = nil, cancelMessage: String? = nil ) {

        let bundle = NSBundle(forClass: TTActionSheet.self)
        super.init(nibName: "TTActionSheet", bundle: bundle)
        self.modalPresentationStyle = .OverCurrentContext
        self.definesPresentationContext = true
        self.transitioningDelegate = transtionController
        self.sheetTitle = title
        self.message = message
        self.cancelMessage = cancelMessage
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidAppear(animated: Bool) {
        let contentHeight = self.collectionView!.contentSize.height
        if contentHeight <= self.collectionView!.frame.height {
            self.collectionView!.scrollEnabled = false
        } else {
            self.collectionView!.scrollEnabled = true
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.frame = UIScreen.mainScreen().bounds
        self.cellController = ActionSheetCellController()
        self.configureUI()
        self.reloadDataSource()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        let contentHeight = self.collectionView!.contentSize.height
        maskViewHeightConstraint.constant = contentHeight + (headerIsVisible ? self.headerView.frame.height : 0)
    }
    
    public func addAction(action: TTActionSheetAction) {
        self.actions.append(action)
    }
    
    func configureUI() {
        self.collectionView?.frame = CGRect(origin: self.collectionView!.frame.origin, size: CGSizeMake(self.collectionView!.frame.width, 0))
        if sheetTitle == nil && message == nil {
            self.headerIsVisible = false
            var newConstraint: NSLayoutConstraint!
            if topCollectionViewConstraint.firstAttribute == NSLayoutAttribute.Top {
                newConstraint = NSLayoutConstraint(item: topCollectionViewConstraint.firstItem, attribute: topCollectionViewConstraint.firstAttribute, relatedBy: topCollectionViewConstraint.relation, toItem: self.maskView , attribute: .Top, multiplier: topCollectionViewConstraint.multiplier, constant: topCollectionViewConstraint.constant)
                maskView.removeConstraint(topCollectionViewConstraint)
            }
            maskView.addConstraint(newConstraint)
            self.headerView.hidden = true
        }
        
        assert(headerIsVisible || actions.count > 0, "No additional information offered, you should have at least a title/message or any action")
        
        if cancelMessage == nil && actions.count > 0 {
            bottomCollectionViewConstraint.constant = -(cancelButton.frame.height)
        } else {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(cancelAction))
            self.dismissView.addGestureRecognizer(gesture)
        }
        
        messageLabel.text = message
        sheetTitleLabel.text = sheetTitle
        cancelButton.setTitle(cancelMessage, forState: .Normal)
        
        blurBgView.effect = UIBlurEffect(style: .ExtraLight)
        maskView.clipsToBounds = true
        maskView.layer.cornerRadius = 12.5
        cancelButton.layer.cornerRadius = 12.5

    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func reloadDataSource() {
        var content:[Any] = []
        content.appendContentsOf(actions.map({ $0 as Any}))
        self.dataSource = DataSource(content)
    }
}
