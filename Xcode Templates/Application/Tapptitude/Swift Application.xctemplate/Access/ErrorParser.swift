//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

enum APIError: String {
    case missingSession = "MissingSession"
}

func ==(lhs: APIError, rhs: Error) -> Bool {
    let error = rhs as NSError
    return error.domain == lhs.rawValue
}

func ==(lhs: Error, rhs: APIError) -> Bool {
    let error = lhs as NSError
    return error.domain == rhs.rawValue
}


class ErrorParser {
    class func parseJSON(_ json: Any?) -> Error? {
        guard let jsonDict = json as? NSDictionary else {
            return NSError(domain: "ErrorParserDomain", code: 1, userInfo: [NSLocalizedDescriptionKey : "Expected a dictionary"])
        }
        
        if let error = jsonDict["error"] as? [String: String] {
            let errorMessage: String! = error["msg"]
            let code: String! = error["code"]
            let invalidSession = code == APIError.missingSession.rawValue
            let error = NSError(domain: code, code: 2, userInfo: [NSLocalizedDescriptionKey : errorMessage])
            if invalidSession {
                DispatchQueue.main.sync(execute: {
                    Session.close(error: error)
                })
            }
            
            return error
        }
        return nil
    }
}
