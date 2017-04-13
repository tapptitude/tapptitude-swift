//
//  ErrorDisplay.swift
//  TestTapptitude
//
//  Created by Alexandru Tudose on 12/04/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import Tapptitude
import UIKit


class ErrorDisplay: TTErrorDisplay {
    
    public class func showError(_ error: NSError, fromViewController: UIViewController) {
        Tapptitude.ErrorDisplay.showError(error, fromViewController: fromViewController)
    }
}

extension UIViewController {
    open func checkAndShow(error: Error?) {
        ErrorDisplay.checkAndShowError(error, fromViewController: self)
    }
}
