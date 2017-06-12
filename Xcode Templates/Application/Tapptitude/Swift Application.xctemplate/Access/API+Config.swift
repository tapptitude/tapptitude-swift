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
    class func request(_ method: HTTPMethod, path: String, serverURL: String = APISettings.serverURL, parameters: [String : Any]? = nil, encoding: Encoding = .url, headers: [String: String]? = nil) -> DataRequest {
        
        let baseURL = URL(string: serverURL)!
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
        
        var encodedURLRequest: URLRequest!
        
        if encoding == .url_json {
//            let urlParameters: [String : Any] = ["api_token" : accessToken]
            encodedURLRequest = API.multiEncodedURLRequest(method: method, url: url, urlParameters: [:], bodyParameters: parameters, headers: mutableHeaders)
        } else {
            let mutableURLRequest = try! URLRequest(url: url, method: method, headers: mutableHeaders)
            encodedURLRequest = try! encoding.encoding.encode(mutableURLRequest, with: parameters)
        }
        
        encodedURLRequest.timeoutInterval = 30.0;//seconds
        
        return Alamofire.request(encodedURLRequest)
    }
    
    class func uploadFile(path: String, serverURL: String, parameters: [String : Any]?, headers: [String: String]? = nil,
                          multipart: (data: Data, name: String, fileName: String, mimeType: String),
                          completionHandler: @escaping (UploadRequest) -> ()) {
        
        let baseURL = NSURL(string: serverURL)!
        guard let url = baseURL.appendingPathComponent(path) else {
            return
        }
        
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
        
        var encodedURLRequest: URLRequest?
        
//        if let accessToken = Session.accessToken {
//            let urlParameters: [String : Any] = ["api_token" : accessToken]
//            encodedURLRequest = API.multiEncodedURLRequest(method: .post, url: url, urlParameters: urlParameters, bodyParameters: nil, headers: mutableHeaders)
//        }
        
        if let encodedURLRequest = encodedURLRequest {
            upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(multipart.data, withName: multipart.name, fileName: multipart.fileName, mimeType: multipart.mimeType)
                if let parameters = parameters {
                    for (key, value) in parameters {
                        multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    }
                }
            }, with: encodedURLRequest) { (result) in
                switch result {
                case .success(let upload, _, _):
                    completionHandler(upload)
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        } else {
            upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(multipart.data, withName: multipart.name, fileName: multipart.fileName, mimeType: multipart.mimeType)
                if let parameters = parameters {
                    for (key, value) in parameters {
                        multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    }
                }
            }, to: url)
            { (result) in
                switch result {
                case .success(let upload, _, _):
                    completionHandler(upload)
                case .failure(let encodingError):
                    print(encodingError)
                }
            }

        }
    }
    
    enum Encoding {
        case json
        case url
        case url_json
        
        var encoding: ParameterEncoding {
            switch self {
            case .json:
                #if DEBUG
                    return JSONEncoding.prettyPrinted
                #else
                    return JSONEncoding.default
                #endif
            case .url: return URLEncoding.default
            case .url_json: return URLEncoding.default
            }
        }
    }
    
    class func multiEncodedURLRequest( method: HTTPMethod, url: URL, urlParameters: [String: Any], bodyParameters: [String: Any]?, headers: [String: String]) -> URLRequest {
        let tempURLRequest = URLRequest(url: url)
        
        var urlRequest = try! Encoding.url.encoding.encode(tempURLRequest, with: urlParameters)
        let bodyRequest = try! Encoding.json.encoding.encode(tempURLRequest, with: bodyParameters)
        
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = bodyRequest.httpBody
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return urlRequest
    }
}

extension DataRequest {
    
    public static func apiErrorResponseSerializer<T>() -> DataResponseSerializer<T> {
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
                    
                    return .success(value as! T)
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
    
    func responseWasCanceled<T>(_ response: DataResponse<T>) -> Bool {
        var canceled = false
        if let error = response.result.error as NSError? {
            canceled = error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled
        }
        
        if self.task?.state == .canceling {
            canceled = true
        }
        
        return canceled
    }
    
    public func responseAPI(_ completion: @escaping (DataResponse<NSDictionary>) -> Void) -> Self {
        let serializer: DataResponseSerializer<NSDictionary> = DataRequest.apiErrorResponseSerializer()
        return validate().response(queue: nil, responseSerializer:serializer , completionHandler: { response in
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



extension Alamofire.Result {
    /**
     Transform the result value, or propagate any errors gracefully.
     This can be used to transform the result without having to verify its content
     - parameters:
     - transform: the closure used to transform the original value
     - returns: a result with the transformed value, or the original error
     */
    public func map<NewValue>(_ transform: (Value) -> NewValue) -> Result<NewValue> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension Alamofire.Result where Value: Collection {
    public func map<NewValue>(as type: NewValue.Type) -> Result<[NewValue]> {
        switch self {
        case .success(let value):
            return .success(value.map({$0 as! NewValue }))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func map<NewValue>() -> Result<[NewValue]> {
        switch self {
        case .success(let value):
            return .success(value.map({$0 as! NewValue }))
        case .failure(let error):
            return .failure(error)
        }
    }
}
