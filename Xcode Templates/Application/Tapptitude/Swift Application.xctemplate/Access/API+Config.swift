//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import Alamofire

extension API {
    /// apply custom API settings like URL, httpheaders
    class func request(method: Alamofire.Method, path: String, parameters: [String : AnyObject]?, encoding: ParameterEncoding = .URL, headers: [String: String]? = nil) -> Request {
        
        let baseURL = NSURL(string: APISettings.serverURL)!
        let url = baseURL.URLByAppendingPathComponent(path)!
        
        // append http headers
        var mutableHeaders : [String : String] = [:]
        if (headers != nil) {
            for (k, v) in headers! {
                mutableHeaders.updateValue(v, forKey: k)
            }
        }
        if let apiHeaders = APISettings().httpHeaders {
            for (k, v) in  apiHeaders {
                mutableHeaders.updateValue(v, forKey: k)
            }
        }
        
        
        
        let mutableURLRequest = URLRequest(method, url, headers: mutableHeaders)
        let encodedURLRequest = encoding.encode(mutableURLRequest, parameters: parameters).0
        encodedURLRequest.timeoutInterval = 30.0;//seconds
        
        return Alamofire.request(encodedURLRequest)
    }
    
    static func URLRequest(method: Alamofire.Method, _ URLString: URLStringConvertible, headers: [String: String]? = nil) -> NSMutableURLRequest {
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URLString.URLString)!)
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let headers = headers {
            for (headerField, headerValue) in headers {
                mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        
        return mutableURLRequest
    }
    
    static func JSONParams(params: [String : AnyObject]?) -> [String : String]? {
        guard params != nil else {
            return nil
        }
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(params!, options: [])
            let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            
            let jsonParams = ["json" : jsonString]
            return jsonParams
        } catch let error {
            print("could not translate \(params) into JSON, \(error)")
            return nil
        }
    }
}

extension Request {
    
    public static func APIErrorResponseSerializer() -> ResponseSerializer<AnyObject, NSError> {
        return ResponseSerializer { request, response, data, error in
            
            guard error == nil else {
                print("! Request failed:", request?.URLString ?? "")
                
                let accessDenied = response?.statusCode == 403 || response?.statusCode == 401
                if accessDenied {
                    dispatch_sync(dispatch_get_main_queue(), {
                        Session.close(error: error)
                    })
                }
                
                return .Failure(error!)
            }
            
            let jsonResponse = Request.JSONResponseSerializer().serializeResponse(request, response, data, error)
            switch jsonResponse {
                case .Success(let value):
                    if response != nil {
                        let apiError = ErrorParser.parseJSON(value)
                        guard apiError == nil else { return .Failure(apiError!) }
                        
                        return .Success(value)
                    } else {
                        let failureReason = "Response collection could not be serialized due to nil response"
                        let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                        return .Failure(error)
                    }
                case .Failure(let error):
                    if let data = data {
                        print("Request failed:", request?.URLString ?? "", "\nResponse:", String(data:data, encoding: NSUTF8StringEncoding) ?? "")
                    }
                    
                    return .Failure(error)
            }
        }
    }
    
    public func responseAPI(completionHandler: Response<AnyObject, NSError> -> Void) -> Self {
        return validate().response(responseSerializer: Request.APIErrorResponseSerializer(), completionHandler: { (response) -> Void in
            var canceled = false
            if let error = response.result.error {
                canceled = error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled
            }
            
            if !canceled {
                completionHandler(response)
            }
        })
    }
}

extension Response {
    /// helper method to show response data as string
    var dataString : String? {
        get {
            return data != nil ? String(data: self.data!, encoding: NSUTF8StringEncoding) : nil
        }
    }
}
