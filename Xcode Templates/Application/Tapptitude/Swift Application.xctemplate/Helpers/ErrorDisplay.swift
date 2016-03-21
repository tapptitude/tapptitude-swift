//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

class ErrorDisplay {
    static func checkAndShowError(error:NSError?, fromViewController:UIViewController?) {
        guard (error != nil) else {
            return
        }
        
        let error = error!
        let ignoreError = ((error.domain == "NSURLErrorDomain" && error.code == -999)
            || (error.domain == "WebKitErrorDomain" && error.code == 102));
        
        if (ignoreError) {
            return;
        }
        
        if fromViewController?.isViewLoaded() == true {
            let isNotVisible = fromViewController?.view.window == nil
            if isNotVisible {
                return
            }
        }
        
        if error.domain == "NSURLErrorDomain" && error.code == NSURLErrorNotConnectedToInternet {
            self.showNoNetworkErrorWithAction(fromViewController)
            return
        }
        
        showErrorWithTitle("Error", message: error.localizedDescription, fromViewController: fromViewController)
    }
    
    static func showNoNetworkError() {
        let message = "The Internet connection appears to be offline."
        showErrorWithTitle("Error", message: message, fromViewController: nil)
    }
    
    static func showErrorWithTitle(title:String, message:String, fromViewController:UIViewController?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        let controller = fromViewController ?? UIApplication.sharedApplication().keyWindow?.rootViewController
        controller?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    static func showErrorWithTitle(title:String, message:String, fromViewController:UIViewController?, _ confirmationAction:()->()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler:{ _ in
            confirmationAction()
        }))
        
        let controller = fromViewController ?? UIApplication.sharedApplication().keyWindow?.rootViewController
        controller?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    static func showErrorWithTitle(title:String, message:String, fromViewController:UIViewController?, actionName: String, _ confirmationAction:()->()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: actionName, style: .Default, handler:{ _ in
            confirmationAction()
        }))
        
        let controller = fromViewController ?? UIApplication.sharedApplication().keyWindow?.rootViewController
        controller?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    static func showNoNetworkErrorWithAction(fromViewController:UIViewController?) {
        let message = "Unable to connect to the internet. Please make sure you have an active internet connection."
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (_) -> Void in
            let url = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(url!)
        }))
        
        let controller = fromViewController ?? UIApplication.sharedApplication().keyWindow?.rootViewController
        controller?.presentViewController(alertController, animated: true, completion: nil)
    }
}


extension UIViewController {
    func checkAndShowError(error : NSError?) {
        ErrorDisplay.checkAndShowError(error, fromViewController:self)
    }
}