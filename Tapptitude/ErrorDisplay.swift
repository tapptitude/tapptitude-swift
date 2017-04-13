//
//  ErrorDisplay.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 12/04/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import UIKit

public protocol TTErrorDisplay: class {
    /// implement a custom way to show errors
    static func showError(_ error: NSError, fromViewController: UIViewController)
}

extension TTErrorDisplay {
    
    /// Errors aren't displayed when viewController is not visible
    public static func checkAndShowError(_ error: Error?, fromViewController: UIViewController) {
        guard let error = error as NSError? else {
            return
        }
        
        let ignoreError = ((error.domain == "NSURLErrorDomain" && error.code == -999)
            || (error.domain == "WebKitErrorDomain" && error.code == 102))
        
        if (ignoreError) {
            return
        }
        
        guard fromViewController.isViewLoaded == true else {
            return
        }
        
        let isVisible = fromViewController.view.window != nil
        guard isVisible else {
            return
        }
        
        if error.domain == "NSURLErrorDomain" && error.code == NSURLErrorNotConnectedToInternet {
            showNoNetworkErrorAlert(fromViewController)
        } else {
            showError(error, fromViewController: fromViewController)
        }
    }
    
    public static func showError(title: String? = "Error", message: String?, fromViewController: UIViewController?,
                                 actionName: String = "OK", _ confirmationAction: @escaping ()->Void = {} ) {
        fromViewController?.showAlert(title: title, message: message, actionName: actionName, confirmationAction)
    }
    
    public static var visibleViewController: UIViewController? {
        var viewController = UIApplication.shared.keyWindow?.rootViewController
        if let presentedViewController = viewController?.presentedViewController {
            viewController = presentedViewController
        }
        return viewController
    }
    
    
    /// Show an alert with "Ok" | "Settings" button --> tap on Settings --> will open Settings pages for this app
    public static func showNoNetworkErrorAlert(_ fromViewController: UIViewController?,
                                               settingsTitle: String = "Settings",
                                               message: String = "Unable to connect to the internet. Please make sure you have an active internet connection.") {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: settingsTitle, style: .default, handler: { (_) -> Void in
            let url = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.openURL(url)
        }))
        
        fromViewController?.present(alertController, animated: true, completion: nil)
    }
}

public class ErrorDisplay: NSObject, TTErrorDisplay {

    public class func showError(_ error: NSError, fromViewController: UIViewController) {
        showError(title: "Error", message: error.localizedDescription, fromViewController: fromViewController)
    }
}



extension UIViewController {
    /// replace default error display class with a custom one
    public static var TTErrorDisplayClass: TTErrorDisplay.Type = ErrorDisplay.self
    
    /// will display errors when viewController is visible
    open func checkAndShow(error: Error?) {
        UIViewController.TTErrorDisplayClass.checkAndShowError(error, fromViewController:self)
    }
    
    open func showAlert(title: String?, message: String?, actionName: String = "OK", _ confirmationAction: @escaping ()->Void = {} ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: actionName, style: .default, handler:{ _ in
            confirmationAction()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
}
