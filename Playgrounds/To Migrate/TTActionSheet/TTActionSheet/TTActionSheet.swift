//
//  TTActionSheet.swift
//  Tapptitude
//
//  Created by Efraim Budusan on 9/6/16.
//  Copyright © 2016 Efraim Budusan. All rights reserved.
//

import UIKit
import Tapptitude
        

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
    var actions: [TTActionSheetActionProtocol] = []
    private var headerIsVisible: Bool = true
    
    let transtionController = DimmingBlurTransition()
    
    var actionSheetController: TTAnyCollectionCellController?
    
    var selectedCallback:((TTActionSheetActionProtocol) -> ())?
    
    public init(title:String? = nil, message:String? = nil, cancelMessage: String? = nil) {
        let bundle = Bundle(for: TTActionSheet.self)
        super.init(nibName: "TTActionSheet", bundle: bundle)
        
        self.modalPresentationStyle = .overCurrentContext
        self.definesPresentationContext = true
        self.transitioningDelegate = transtionController
        self.sheetTitle = title
        self.message = message
        self.cancelMessage = cancelMessage
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let controller = actionSheetController {
            self.cellController = controller
        } else {
            self.cellController = ActionSheetCellController<TTActionSheetAction,ActionSheetCell>()
        }
        
        if Bundle.allBundles.contains(where: { ($0.bundleIdentifier ?? "").hasPrefix("com.apple.dt.") }) {
            self.view.frame = CGRect(x: 0, y: 0, width: 350, height: 667) // harcoded value
            print("in playground --> TTActionSheet size harcoded to: ", self.view.frame.size)
        } else {
//            print("not in playground")
            self.view.frame = UIScreen.main.bounds
        }
        
        self.configureUI()
        self.reloadDataSource()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        let contentHeight = self.collectionView!.contentSize.height
        maskViewHeightConstraint.constant = contentHeight + (headerIsVisible ? self.headerView.frame.height : 0)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        let contentHeight = self.collectionView!.contentSize.height
        if contentHeight <= self.collectionView!.frame.height {
            self.collectionView!.isScrollEnabled = false
        } else {
            self.collectionView!.isScrollEnabled = true
        }
    }
    
    public func addAction(action: TTActionSheetAction) {
        self.actions.append(action)
        self.reloadDataSource()
    }
    
    func configureUI() {
        self.collectionView?.frame = CGRect(origin: self.collectionView!.frame.origin, size: CGSize(width:self.collectionView!.frame.width,height: 0))
        if sheetTitle == nil && message == nil {
            self.headerIsVisible = false
            var newConstraint: NSLayoutConstraint!
            if topCollectionViewConstraint.firstAttribute == NSLayoutAttribute.top {
                newConstraint = NSLayoutConstraint(item: topCollectionViewConstraint.firstItem, attribute: topCollectionViewConstraint.firstAttribute, relatedBy: topCollectionViewConstraint.relation, toItem: self.maskView , attribute: .top, multiplier: topCollectionViewConstraint.multiplier, constant: topCollectionViewConstraint.constant)
                maskView.removeConstraint(topCollectionViewConstraint)
            }
            maskView.addConstraint(newConstraint)
            self.headerView.isHidden = true
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
        cancelButton.setTitle(cancelMessage, for: .normal)
        
        blurBgView.effect = UIBlurEffect(style: .extraLight)
        maskView.clipsToBounds = true
        maskView.layer.cornerRadius = 12.5
        cancelButton.layer.cornerRadius = 12.5
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func reloadDataSource() {
        self.dataSource = DataSource(actions)
        
        if isViewLoaded {
            let contentHeight = self.collectionView!.contentSize.height
            maskViewHeightConstraint.constant = contentHeight + (headerIsVisible ? self.headerView.frame.height : 0)
        }
    }
}
