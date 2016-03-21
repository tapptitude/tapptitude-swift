//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

class ErrorParser {
    class func parseJSON(json:AnyObject?) -> NSError? {
        guard let jsonDict = json as? NSDictionary else {
            return NSError(domain: "ErrorParserDomain", code: 1, userInfo: [NSLocalizedDescriptionKey : "Expected a dictionary"])
        }
        
        if let errorMessage = jsonDict["error"] as? String {
//            let invalidSession = code == "no_session"
//            if invalidSession {
//                Session.closeWithError(error)
//            }
            
            return NSError(domain: APISettings.errorDomain, code: 2, userInfo: [NSLocalizedDescriptionKey : errorMessage])
        }
        
        
        
        return nil
    }
}
