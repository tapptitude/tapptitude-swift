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
        return FBSDKAccessToken.current().tokenString != nil && FBSDKAccessToken.current().expirationDate.timeIntervalSinceNow > 0.0
    }
    
    static func accessToken() -> String {
        return FBSDKAccessToken.current().tokenString
    }
    
    static func expirationDate() -> Date {
        return FBSDKAccessToken.current().expirationDate
    }
    
    static func loginFromViewController(_ fromController: UIViewController?, callback:@escaping (_ userCanceled : Bool, _ error : Error?) -> Void) {
        manager.logIn(withReadPermissions: ["email","public_profile"], from: fromController) { (result, error) -> Void in
            let didCancel = result?.isCancelled ?? false
            callback( didCancel == true, error)
        }
    }
    
    static func getUserInfo( _ callback: @escaping ( _ email:String?, _ first_name:String?, _ last_name: String?, _ photoUrl:String?, _ error: Error?) -> () ){
        let request: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "email,first_name,last_name,picture"], httpMethod: "GET")
        request.start { (connection, result, error) in
            if let dict = result as? NSDictionary {
                let email = dict.value(forKey: "email") as! String
                let first_name = dict.value(forKey: "first_name") as? String
                let last_name = dict.value(forKey: "last_name") as? String
                let picture = dict.value(forKeyPath: "picture.data.url") as? String
                callback(email, first_name, last_name, picture, nil)
            } else {
                callback(nil, nil, nil, nil, error)
            }
        }
    }
    
    static func logout() {
        manager.logOut()
    }
    
    static func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    static func application(_ app: UIApplication, openURL url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: [])
    }
    
    static func application(_ application: UIApplication!, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]!) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
