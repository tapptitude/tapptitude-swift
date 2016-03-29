//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

struct APISettings {
    static let serverURL = Constants.API_URL
    static let errorDomain = "API+___PROJECTNAME___"
    
    var httpHeaders: [String: String]? {
        var headers =  [String:String]()
        headers["Authorization"] = Session.accessToken() != nil ? ("Token " + Session.accessToken()!) : nil
        headers["Identity"] = Session.currentUserID() != nil ? ("Email " + Session.currentUserID()!) : nil
        headers["API_KEY"] = Constants.API_KEY
        return headers
    }
}


class API {
    //    static func getLandingIntro(callback:(pages:[IntroPage]?, error:NSError?)->()) -> Alamofire.Request {
    //        let params = ["device_type" : UIDevice.currentDevice().model]
    //
    //        return self.request(.GET, path: "intro", parameters: JSONParams(params)).responseAPI({ response in
    //            let parsedObject = Mapper<IntroPage>().mapArray(response.result.value?["data"])
    //            callback(pages:parsedObject, error:response.result.error)
    //        })
    //    }
    
    // MARK: - Login
    
    static func loginWithEmail(email:String, callback:(user:User?, message:String?, error:NSError?)->()) -> Alamofire.Request {
        let params = ["email" : email]
        
        return self.request(.POST, path: "enter/", parameters: params).responseAPI({ response in
            guard response.result.error == nil else {
                callback(user:nil, message: nil, error: response.result.error)
                return
            }
            
            //            let parseResponse = SessionParser.parseJSON(response.result.value)
            //            if parseResponse.user != nil {
            //                API.getUserProfileAfterLogin({ (error) -> () in
            //                    callback(user:parseResponse.user, message: nil, error: error)
            //                })
            //            } else {
            //                Session.saveUserID(email, accessToken: nil) // save user email
            //
            //                callback(user: parseResponse.user, message: parseResponse.message, error: parseResponse.error)
            //            }
        })
    }
    
    static func loginWithFacebook(fbAuthToken:String, callback:(user:User?, error:NSError?)->()) -> Alamofire.Request {
        let headers = ["FACEBOOK" : "TOKEN \(fbAuthToken)"]
        
        return self.request(.POST, path: "enter/", parameters: nil, encoding: .URL, headers:headers).responseAPI({ response in
            print(response.result.error)
            guard response.result.error == nil else {
                callback(user: nil, error: response.result.error)
                return
            }
            
            //            let parseResponse = SessionParser.parseJSON(response.result.value)
            //            if parseResponse.user != nil {
            //                API.getUserProfileAfterLogin({ (error) -> () in
            //                    callback(user:parseResponse.user, error: error)
            //                })
            //            } else {
            //                callback(user: parseResponse.user, error: parseResponse.error)
            //            }
        })
    }
    
    static func loginWithToken(token:String, callback:(user:User?, error:NSError?)->()) -> Alamofire.Request {
        let headers = ["Authorization" : "Token \(token)"]
        
        return self.request(.POST, path: "enter/", parameters: nil, encoding: .URL, headers:headers).responseAPI({ response in
            guard response.result.error == nil else {
                callback(user: nil, error: response.result.error)
                return
            }
            
            //            let parseResponse = SessionParser.parseJSON(response.result.value)
            //            if parseResponse.user != nil {
            //                API.getUserProfileAfterLogin({ (error) -> () in
            //                    callback(user:parseResponse.user, error: error)
            //                })
            //            } else {
            //                callback(user: parseResponse.user, error: parseResponse.error)
            //            }
        })
    }
}