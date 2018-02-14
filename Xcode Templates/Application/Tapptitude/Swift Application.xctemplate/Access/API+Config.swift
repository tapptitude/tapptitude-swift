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
        
//        let pathComponents = URLComponents(string: path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)!
//        var serverComponents = URLComponents(string: serverURL)!
//        let completePath = (serverComponents.path + "/" + pathComponents.path).replacingOccurrences(of: "//", with: "/")
//        serverComponents.path = completePath
//        serverComponents.query = pathComponents.query
//        let url = serverComponents.url!
        let url = URL(string: serverURL)!.appendingPathComponent(path)
        
        // append http headers
        var mutableHeaders : [String : String] = headers ?? [:]
        for (k, v) in APISettings().httpHeaders ?? [:] {
            mutableHeaders.updateValue(v, forKey: k)
        }
        
        var request = try! URLRequest(url: url, method: method, headers: mutableHeaders)
        
        switch encoding {
        case .url_jsonQuery:
            // params into a JSON ---> ?json=json
            if let params = parameters {
                let data = try! JSONSerialization.data(withJSONObject: params, options: [])
                let json = String(data: data, encoding: .utf8)!
                request = try! URLEncoding.default.encode(request, with: ["json": json])
            }
        case .url, .json:
            request = try! encoding.default.encode(request, with: parameters)
        }
        
        request.timeoutInterval = 30.0;//seconds
        
        return Alamofire.request(request)
    }
    
    class func uploadFile(path: String, serverURL: String, parameters: [String : Any]?, headers: [String: String]? = nil,
                          multipart: (data: Data, name: String, fileName: String, mimeType: String),
                          completionHandler: @escaping (UploadRequest) -> ()) {
        
        let url = URL(string: serverURL)!.appendingPathComponent(path)
        
        // append http headers
        var mutableHeaders : [String : String] = headers ?? [:]
        for (k, v) in APISettings().httpHeaders ?? [:] {
            mutableHeaders.updateValue(v, forKey: k)
        }
        
        let request = try! URLRequest(url: url, method: .post, headers: mutableHeaders)
        
        upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(multipart.data, withName: multipart.name, fileName: multipart.fileName, mimeType: multipart.mimeType)
            for (key, value) in parameters ?? [:] {
                let stringValue = String(describing: value)
                multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
            }
        }, with: request) { (result) in
            switch result {
            case .success(let upload, _, _):
                completionHandler(upload)
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    enum Encoding {
        case json
        case url
        case url_jsonQuery
        
        var `default`: ParameterEncoding {
            switch self {
            case .json:
                #if DEBUG
                    return JSONEncoding.prettyPrinted
                #else
                    return JSONEncoding.default
                #endif
            case .url: return URLEncoding.default
            case .url_jsonQuery: abort()
            }
        }
    }
}

extension DataRequest {
    
    public static func apiErrorResponseSerializer() -> DataResponseSerializer<()> {
        return DataResponseSerializer { request, response, data, error in
            
            var apiError = error
            if let data = data {
                apiError = (try? JSONDecoder().decode(APIError.self, from: data)) ?? apiError
            }
            
            guard apiError == nil else {
                print("\n❗ Request failed: ",
                      request?.httpMethod ?? "",
                      request?.url?.absoluteString ?? "",
                      "\n\tResponse: " + (data.flatMap({ String(data:$0, encoding: .utf8) }) ?? ""))
                
                
                let missingSession = (apiError as? APIError)?.type == .missingSession
                let accessDenied = response?.statusCode == 403 || response?.statusCode == 401 || missingSession
                if accessDenied {
                    DispatchQueue.main.async {
                        Session.close(error: apiError!)
                    }
                }
                
                return .failure(apiError!)
            }
            
            return .success(())
        }
    }
    
    public func responseAPIDecode<T: Decodable>(decoder: JSONDecoder = JSONDecoder(), keyPath: String? = nil,
                                                completion: @escaping (DataResponse<T>, Tapptitude.Result<T>) -> ()) -> Self {
        let serializer: DataResponseSerializer<T> = DataRequest.apiDecodableSerializer(decoder: decoder, keyPath: keyPath)
        return validate().response(queue: nil, responseSerializer: serializer, completionHandler: { response in
            if !self.responseWasCanceled(response) {
                let result: Tapptitude.Result<T> = response.result.map({ $0 })
                completion(response, result)
            }
        })
    }
    
    public static func apiDecodableSerializer<T: Decodable>(decoder: JSONDecoder, keyPath: String? = nil) -> DataResponseSerializer<T> {
        return DataResponseSerializer { request, response, data, error in
            let result = apiErrorResponseSerializer().serializeResponse(request, response, data, error)
            switch result {
            case .success(_):
                do {
                    var object:T
                    if let keyPath = keyPath {
                        object = try decoder.decode(T.self, from: data!, keyPath: keyPath, separator: ".")
                    } else {
                        object = try decoder.decode(T.self, from: data!)
                    }
                    return .success(object)
                }
                catch {
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    
    public static func apiJSONSerializer<T>(keyPath: String? = nil) -> DataResponseSerializer<T> {
        return DataResponseSerializer { request, response, data, error in
            let result = apiErrorResponseSerializer().serializeResponse(request, response, data, error)
            switch result {
            case .success(_):
                let jsonResponse = Request.serializeResponseJSON(options: [], response: response, data: data, error: error)
                switch jsonResponse {
                case .success(let value):
                    var newValue: Any? = value
                    if let keyPath = keyPath {
                        if let dictValue = value as? NSDictionary {
                            newValue = dictValue.value(forKeyPath: keyPath)
                        } else {
                            let failureReason = "Unexpected response format. Expected: NSDictionary ---> got: \(String(describing: newValue))"
                            let error = NSError(domain: APISettings.errorDomain, code: 2, userInfo: [NSLocalizedDescriptionKey : failureReason])
                            return .failure(error)
                        }
                    }
                    
                    if let value = newValue as? T {
                        return .success(value)
                    } else {
                        let failureReason = "Unexpected response format. Expected: \(T.self) ---> got: \(String(describing: newValue))"
                        let error = NSError(domain: APISettings.errorDomain, code: 2, userInfo: [NSLocalizedDescriptionKey : failureReason])
                        return .failure(error)
                    }
                case .failure(let error):
                    if let data = data {
                        print("Request failed:", request?.url?.absoluteString ?? "", "\nResponse:", String(data:data, encoding: String.Encoding.utf8) ?? "")
                    }
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    public func responseAPI_JSON<T>(keyPath: String? = nil, _ completion: @escaping (DataResponse<T>) -> Void) -> Self {
        let serializer: DataResponseSerializer<T> = DataRequest.apiJSONSerializer(keyPath: keyPath)
        return validate().response(queue: nil, responseSerializer: serializer , completionHandler: { response in
            if !self.responseWasCanceled(response) {
                completion(response)
            }
        })
    }
    
    public func responseAPI(_ completion: @escaping (DataResponse<()>) -> Void) -> Self {
        let serializer = DataRequest.apiErrorResponseSerializer()
        return validate().response(queue: nil, responseSerializer: serializer , completionHandler: { response in
            if !self.responseWasCanceled(response) {
                completion(response)
            }
        })
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
}

import Tapptitude
extension Alamofire.Request: TTCancellable {
}

extension Alamofire.DataResponse {
    /// helper method to show response data as string
    var dataAsString : String? {
        get {
            return data != nil ? String(data: self.data!, encoding: .utf8) : nil
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
    public func map<NewValue>(_ transform: (Value) -> NewValue) -> Tapptitude.Result<NewValue> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension Alamofire.Result where Value: Collection {
    public func map<NewValue>(as type: NewValue.Type) -> Tapptitude.Result<[NewValue]> {
        switch self {
        case .success(let value):
            return .success(value.map({$0 as! NewValue }))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func map<NewValue>() -> Tapptitude.Result<[NewValue]> {
        switch self {
        case .success(let value):
            return .success(value.map({$0 as! NewValue }))
        case .failure(let error):
            return .failure(error)
        }
    }
}

