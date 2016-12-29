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
    class func request(_ method: HTTPMethod, path: String, parameters: [String : Any]? = nil, encoding: Encoding = .url, headers: [String: String]? = nil) -> DataRequest {
        
        let baseURL = URL(string: APISettings.serverURL)!
        let url = baseURL.appendingPathComponent(path)
        
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
        
        let mutableURLRequest = try! URLRequest(url: url, method: method, headers: mutableHeaders)
        var encodedURLRequest = try! encoding.encoding.encode(mutableURLRequest, with: parameters)
        encodedURLRequest.timeoutInterval = 30.0;//seconds
        
        return Alamofire.request(encodedURLRequest)
    }
    
    enum Encoding {
        case json
        case url
        
        var encoding: ParameterEncoding {
            switch self {
            case .json:
                #if DEBUG
                    return JSONEncoding.prettyPrinted
                #else
                    return JSONEncoding.default
                #endif
            case .url: return URLEncoding.default
            }
        }
    }
}

extension DataRequest {
    
    public static func apiErrorResponseSerializer() -> DataResponseSerializer<NSDictionary> {
        return DataResponseSerializer { request, response, data, error in
            
            guard error == nil else {
                print("! Request failed:", request?.url?.absoluteString ?? "")
                
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    if let apiError = ErrorParser.parseJSON(json) {
                        return .failure(apiError)
                    }
                }
                
                let accessDenied = response?.statusCode == 403 || response?.statusCode == 401
                if accessDenied {
                    DispatchQueue.main.async {
                        Session.close(error: error)
                    }
                }
                
                return .failure(error!)
            }
            
            let jsonResponse = Request.serializeResponseJSON(options: [], response: response, data: data, error: error)
            switch jsonResponse {
            case .success(let value):
                if response != nil {
                    let apiError = ErrorParser.parseJSON(value)
                    guard apiError == nil else { return .failure(apiError!) }
                    
                    return .success(value as! NSDictionary)
                } else {
                    let failureReason = "Response collection could not be serialized due to nil response"
                    let error = NSError(domain: APISettings.errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey : failureReason])//Error.Code.JSONSerializationFailed.rawValue
                    return .failure(error)
                }
            case .failure(let error):
                if let data = data {
                    print("Request failed:", request?.url?.absoluteString ?? "", "\nResponse:", String(data:data, encoding: String.Encoding.utf8) ?? "")
                }
                return .failure(error)
            }
        }
    }
    
    func completionHanderCheckForCancel<T>(_ completionHandler: @escaping (DataResponse<T>) -> Void) -> ((DataResponse<T>) -> Void) {
        let closure: ((DataResponse<T>) -> Void) = { (response) in
            if !self.responseWasCanceled(response) {
                completionHandler(response)
            }
        }
        
        return closure
    }
    
    func responseWasCanceled<T>(_ response: DataResponse<T>) -> Bool {
        var canceled = false
        if let error = response.result.error as? NSError {
            canceled = error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled
        }
        
        if self.task?.state == .canceling {
            canceled = true
        }
        
        return canceled
    }
    
    public func responseAPI(_ completion: @escaping (DataResponse<NSDictionary>) -> Void) -> Self {
        return validate().response(queue: nil, responseSerializer: DataRequest.apiErrorResponseSerializer(), completionHandler: { response in
            if !self.responseWasCanceled(response) {
                completion(response)
            }
        })
    }
}

import Tapptitude
extension Alamofire.Request: TTCancellable {
}

extension Alamofire.DataResponse {
    /// helper method to show response data as string
    var dataAsString : String? {
        get {
            return data != nil ? String(data: self.data!, encoding: String.Encoding.utf8) : nil
        }
    }
}
