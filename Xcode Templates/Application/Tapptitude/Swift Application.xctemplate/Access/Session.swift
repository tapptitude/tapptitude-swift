//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import UIKit
import SSKeychain

struct SessionInfo {
    static let previouslyLoggedUser = "previouslyLoggedUser"
    
    static let keychainService = "Test"
    static let userID = "email"
    static let accessToken = "token"
    
    static let sessionClosedNotificationKey = "sessionClosedNotification"
    static let sessionClosedNotificationErrorKey = "error"
}

class Session {
    static func isValidSession() -> Bool {
        let userID = self.currentUserID() as NSString?
        let accessToken = self.accessToken() as NSString?
        
        return userID?.length > 0 && accessToken?.length > 0
    }
    
    static func shouldRestoreUserSession () -> Bool {
        let user = currentUser()
        let isComplete = user?.firstName?.isEmpty == false && user?.lastName?.isEmpty == false
        return !isComplete
    }
    
    static func closeWithError(error: NSError?) {
        guard self.isValidSession() else {
            return
        }
        
        self.removeUserIDAndAccessToken()
        let shouldRemoveUserCredential = (error == nil);
        if (shouldRemoveUserCredential) {
            Session.clearUserCredentials()
        }
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        var userInfo : [NSObject : AnyObject]? = nil
        if (error != nil) {
            userInfo = [SessionInfo.sessionClosedNotificationErrorKey : error!]
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(SessionInfo.sessionClosedNotificationKey, object: self, userInfo: userInfo)
    }
    
    //MARK:User
    class func accessToken () -> String? {
        return keychainValueForKey(SessionInfo.accessToken)
    }
    static func currentUserID () -> String? {
        return keychainValueForKey(SessionInfo.userID)
    }
    
    static func currentUser () -> User? {
        if let userID = currentUserID() {
            let user = User()
            user.userID = userID
            return user
        }
        
        return nil
    }
    
    static func saveUserID(userID:String, accessToken:String?) {
        // check for previous logged user, if is the case delete it's cached content
        let previousUserID = NSUserDefaults.standardUserDefaults().stringForKey(SessionInfo.previouslyLoggedUser)
        if previousUserID != nil && userID != previousUserID {
            clearUserCredentials()
        }
        NSUserDefaults.standardUserDefaults().setObject(userID, forKey: SessionInfo.previouslyLoggedUser)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // save user credentials
        setKeychainValue(userID, forKey: SessionInfo.userID)
        setKeychainValue(accessToken, forKey: SessionInfo.accessToken)
    }
    
    static func removeUserIDAndAccessToken() {
        setKeychainValue(nil, forKey: SessionInfo.userID)
        setKeychainValue(nil, forKey: SessionInfo.accessToken)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func setKeychainValue(value: String?, forKey key: String) {
        if let value = value {
            SSKeychain.setPassword(value, forService: SessionInfo.keychainService, account: key)
        } else {
            SSKeychain.deletePasswordForService(SessionInfo.keychainService, account: key)
        }
    }
    
    static func keychainValueForKey(key: String) -> String? {
        return SSKeychain.passwordForService(SessionInfo.keychainService, account: key)
    }
}

extension Session {
    static private func clearUserCredentials() {
        let savedUserID = NSUserDefaults.standardUserDefaults().objectForKey(SessionInfo.previouslyLoggedUser) as? String;
        guard savedUserID != nil else {
            return
        }
        
        // Delete login service token & username
        let loginService = SessionInfo.keychainService
        let password = SSKeychain.passwordForService(loginService, account: savedUserID)
        if (password != nil) {
            SSKeychain.deletePasswordForService(loginService, account:savedUserID)
        }
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(SessionInfo.previouslyLoggedUser)
    }
}