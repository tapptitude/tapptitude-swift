//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import Alamofire
import Tapptitude

struct APISettings {
    static let serverURL = Constants.API_URL
    static let errorDomain = "API+___PROJECTNAME___"
    
    var httpHeaders: [String: String]? {
        var headers =  [String:String]()
        headers["authorization"] = Session.accessToken
        headers["API_KEY"] = Constants.API_KEY
        return headers
    }
}

typealias Result = Tapptitude.Result

class API {
    
    @discardableResult
    static func loginWithEmail(_ email: String, password: String, callback: @escaping (_ result: Result<User>)->()) -> TTCancellable? {
        let params : [String: Any] = [ "email":email, "password": password]
        
        return request(.post, path: "/driver/users/login", parameters: params, encoding: .json).responseAPIDecode(keyPath: "data") { (response,  result: Result<LoginSession>) in
            if let session = result.value {
                Session.accessToken = session.token
                Session.currentUserID = session.driver.userID
            }
            
            callback(result.map({ $0.driver }))
        }
    }
    
    @discardableResult
    static func getCurrentUser(_ callback:@escaping (_ result: Result<User>)->()) -> TTCancellable? {
        return request(.get, path: "driver/users").responseAPIDecode(keyPath: "data", completion: { (response, result) in
            callback(result)
        })
    }
    
    @discardableResult
    static func logout(_ callback:@escaping (_ error: Error?)->()) -> TTCancellable? {
        return request(.post, path: "driver/users/logout").responseAPI({ response in
            callback(response.result.error)
        })
    }
    
    
//    @discardableResult
//    static func getBookingHistory(limit:Int, fromBookingId:String?, callback: @escaping (_ bookings: [Booking]?,  _ nextOffset: String?, _ error: Error?) ->()) -> TTCancellable?  {
//        var params:[String:Any] = [:]
//        params["limit"] = limit
//        params["from_booking_id"] = fromBookingId
//        params["statuses"] = []
//
//        return request(.get, path: "driver/bookings", parameters: params, encoding: .url).responseAPIDecode(keyPath: "data") { (response, bookings: [Booking]?) in
//            let lastBookingId = bookings?.last?.id
//            callback(bookings, lastBookingId,  response.result.error)
//        }
//    }
}
