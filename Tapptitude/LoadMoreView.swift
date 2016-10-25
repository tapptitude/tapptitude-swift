//
//  LoadMoreView.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

open class LoadMoreView : UICollectionReusableView {
    
    @IBOutlet weak open var loadingView: UIActivityIndicatorView?
    
    open func startAnimating() {
        loadingView?.startAnimating()
    }
    open func stopAnimating() {
        loadingView?.stopAnimating()
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        backgroundColor = newSuperview?.backgroundColor
        loadingView?.backgroundColor = backgroundColor
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        loadingView?.center = center
    }
}
