//
//  TTSpinnerView.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 26/06/2017.
//
//

import UIKit

@objc public protocol TTSpinnerView {
    func startAnimating() // should show view if necessary
    func stopAnimating() // should hide view if necessary
}


extension UIActivityIndicatorView: TTSpinnerView {
    
}
