//
//  LoadMoreView.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

public class LoadMoreView : UICollectionReusableView {
    
    @IBOutlet weak public var loadingView: UIActivityIndicatorView?
    
    public func startAnimating() {
        loadingView?.startAnimating()
    }
    public func stopAnimating() {
        loadingView?.stopAnimating()
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        backgroundColor = newSuperview?.backgroundColor
        loadingView?.backgroundColor = backgroundColor
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        loadingView?.center = center
    }
}
