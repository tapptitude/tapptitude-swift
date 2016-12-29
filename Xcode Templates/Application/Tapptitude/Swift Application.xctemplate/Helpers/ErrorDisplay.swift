//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import SwiftMessages

class ErrorDisplay {
    static func checkAndShowError(_ error:NSError?, fromViewController:UIViewController?) {
        guard (error != nil) else {
            return
        }
        
        let error = error!
        let ignoreError = ((error.domain == "NSURLErrorDomain" && error.code == -999)
            || (error.domain == "WebKitErrorDomain" && error.code == 102));
        
        if (ignoreError) {
            return;
        }
        
        if fromViewController?.isViewLoaded == true {
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
    
    static func showSuccesWith(title:String, andMessage message:String, fromViewController:UIViewController) {
        var view:MessageView!
        if #available(iOS 9.0, *) {
            view = MessageView.viewFromNib(layout: .CardView)
        } else {
            view = MessageView.viewFromNib(layout: .MessageViewIOS8)
        }
        view.configureTheme(.success)
        view.configureContent(title: title, body: message)
        view.button?.setTitle("Ok", for: .normal)
        view.buttonTapHandler = { (button: UIButton) -> Void in  SwiftMessages.hide() }
        view.backgroundView.backgroundColor = UIColorFromRGB(0x79D760)
        SwiftMessages.show(view: view)
    }
    
    static func showErrorWithTitle(_ title:String, message:String, fromViewController:UIViewController?) {
        var view:MessageView!
        if #available(iOS 9.0, *) {
            view = MessageView.viewFromNib(layout: .CardView)
        } else {
            view = MessageView.viewFromNib(layout: .MessageViewIOS8)
        }
        view.configureTheme(.error)
        view.configureContent(title: title, body: message)
        view.button?.removeFromSuperview()
        
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        
        SwiftMessages.show(config: config, view: view)
        //        SwiftMessages.show(view: view)
    }
    
    static func showErrorWithTitle(_ title:String, message:String, fromViewController:UIViewController?, _ confirmationAction:@escaping ()->()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler:{ _ in
            confirmationAction()
        }))
        
        let controller = fromViewController ?? UIApplication.shared.keyWindow?.rootViewController
        controller?.present(alertController, animated: true, completion: nil)
    }
    
    static func showErrorWithTitle(_ title:String, message:String, fromViewController:UIViewController?, actionName: String, _ confirmationAction:@escaping ()->()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: actionName, style: .default, handler:{ _ in
            confirmationAction()
        }))
        
        let controller = fromViewController ?? UIApplication.shared.keyWindow?.rootViewController
        controller?.present(alertController, animated: true, completion: nil)
    }
    
    static func showNoNetworkErrorWithAction(_ fromViewController:UIViewController?) {
        let message = "Unable to connect to the internet. Please make sure you have an active internet connection."
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (_) -> Void in
            let url = URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.openURL(url!)
        }))
        
        let controller = fromViewController ?? UIApplication.shared.keyWindow?.rootViewController
        controller?.present(alertController, animated: true, completion: nil)
    }
}


extension UIViewController {
    func checkAndShowError(_ error : NSError?) {
        ErrorDisplay.checkAndShowError(error, fromViewController:self)
    }
    
    func checkAndShow(error : Error?) {
        ErrorDisplay.checkAndShowError(error as? NSError , fromViewController:self)
    }
}
