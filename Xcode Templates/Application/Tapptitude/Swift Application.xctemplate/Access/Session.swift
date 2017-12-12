//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import UIKit
import SAMKeychain

struct SessionInfo {
    static let previouslyLoggedUser = "previouslyLoggedUser"
    
    static let keychainService = "Test"
    static let userID = "email"
    static let accessToken = "token"
    
    static let sessionClosedNotification = Notification.Name(rawValue: "sessionClosedNotification")
    static let sessionClosedNotificationErrorKey = "error"
}

class Session {
    static func isValidSession() -> Bool {
        return currentUserID?.isEmpty == false && accessToken?.isEmpty == false
    }
    
    static func shouldRestoreUserSession () -> Bool {
        let user = currentUser()
        let isComplete = user?.firstName?.isEmpty == false && user?.lastName?.isEmpty == false
        return !isComplete
    }
    
    static func close(error: Error? = nil) {
        guard self.isValidSession() else {
            return
        }
        
        Facebook.logout()
        
        self.removeUserIDAndAccessToken()
        let shouldRemoveUserCredential = (error == nil);
        if (shouldRemoveUserCredential) {
            Session.clearUserCredentials()
        }
        
        UIApplication.shared.cancelAllLocalNotifications()
        
        var userInfo : [AnyHashable: Any]? = nil
        if (error != nil) {
            userInfo = [SessionInfo.sessionClosedNotificationErrorKey : error!]
        }
        
        NotificationCenter.default.post(name: SessionInfo.sessionClosedNotification, object: self, userInfo: userInfo)
    }
    
    //MARK:User
    static var accessToken: String? {
        get { return UserDefaults.standard.string(forKey: SessionInfo.accessToken) }
        set { UserDefaults.standard.setValue(newValue, forKey: SessionInfo.accessToken) }
    }
    
    static var currentUserID: String? {
        get { return UserDefaults.standard.string(forKey: SessionInfo.userID) }
        set { UserDefaults.standard.setValue(newValue, forKey: SessionInfo.userID) }
    }
    
    static func currentUser () -> User? {
        if let userID = currentUserID {
            var user = User()
            user.userID = userID
            return user
        }
        
        return nil
    }
    
    static func saveUserID(userID:String, accessToken:String?) {
        // check for previous logged user, if is the case delete it's cached content
        let previousUserID = UserDefaults.standard.string(forKey: SessionInfo.previouslyLoggedUser)
        if previousUserID != nil && userID != previousUserID {
            clearUserCredentials()
        }
        UserDefaults.standard.set(userID, forKey: SessionInfo.previouslyLoggedUser)
        UserDefaults.standard.synchronize()
        
        // save user credentials
        Session.currentUserID = userID
        Session.accessToken = accessToken
    }
    
    static func removeUserIDAndAccessToken() {
        Session.currentUserID = nil
        Session.accessToken = nil
        UserDefaults.standard.synchronize()
    }
    
    static func setKeychainValue(value: String?, forKey key: String) {
        if let value = value {
            SAMKeychain.setPassword(value, forService: SessionInfo.keychainService, account: key)
        } else {
            SAMKeychain.deletePassword(forService: SessionInfo.keychainService, account: key)
        }
    }
    
    static func keychainValueForKey(key: String) -> String? {
        return SAMKeychain.password(forService: SessionInfo.keychainService, account: key)
    }
}

extension Session {
    static fileprivate func clearUserCredentials() {
        guard let savedUserID = UserDefaults.standard.object(forKey: SessionInfo.previouslyLoggedUser) as? String else {
            return
        }
        
        // Delete login service token & username
        let loginService = SessionInfo.keychainService
        let password = SAMKeychain.password(forService: loginService, account: savedUserID)
        if (password != nil) {
            SAMKeychain.deletePassword(forService: loginService, account:savedUserID)
        }
        
        UserDefaults.standard.removeObject(forKey: SessionInfo.previouslyLoggedUser)
    }
}
