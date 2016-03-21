//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

class Facebook {
    static let manager: FBSDKLoginManager = FBSDKLoginManager()
    
    static func isOpen() -> Bool {
        return FBSDKAccessToken.currentAccessToken().tokenString != nil && FBSDKAccessToken.currentAccessToken().expirationDate.timeIntervalSinceNow > 0.0
    }
    
    static func accessToken() -> String {
        let token: String = FBSDKAccessToken.currentAccessToken().tokenString
        return token
    }
    
    static func expirationDate() -> NSDate {
        return FBSDKAccessToken.currentAccessToken().expirationDate
    }
    
    static func loginFromViewController(fromController: UIViewController?, callback:(userCanceled : Bool, error : NSError?) -> Void) {
//        manager.loginBehavior = .Web
        manager.logInWithReadPermissions(["email"], fromViewController: fromController) { (result, error) -> Void in
            callback(userCanceled: result.isCancelled, error: error)
        }
    }
    
    static func logout() {
        manager.logOut()
    }
    
    static func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    static func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if #available(iOS 9.0, *) {
            let sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String
            return FBSDKApplicationDelegate.sharedInstance().application(app, openURL: url, sourceApplication: sourceApplication, annotation: [])
        } else {
            return false
        }

    }
    
    static func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]!) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}