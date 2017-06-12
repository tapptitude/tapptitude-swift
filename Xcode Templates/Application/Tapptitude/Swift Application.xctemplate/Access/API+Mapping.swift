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
import Tapptitude

public typealias Result = Tapptitude.Result

extension DataRequest {
    public func responseAPIMap<T: Mappable>(keyPath: String? = nil, completion: @escaping (DataResponse<NSDictionary>, Result<T>) -> ()) -> Self {
        let mapperSerializer: DataResponseSerializer<(json: NSDictionary, item: T)> = DataRequest.objectMapperSerializer(keyPath: keyPath)
        return validate().response(queue: nil, responseSerializer: mapperSerializer, completionHandler: { response in
            if !self.responseWasCanceled(response) {
                let ourResult = response.result.isSuccess ? Result.success(response.result.value!.item) : Result.failure(response.result.error!)
                let result = response.result.isSuccess ? Alamofire.Result.success(response.result.value!.json) : Alamofire.Result.failure(response.result.error!)
                let dataResponse = DataResponse(request: response.request, response: response.response, data: response.data, result: result, timeline: response.timeline)

                completion(dataResponse, ourResult)
            }
        })
    }
    
    public func responseAPIMap<T: Mappable>(keyPath: String? = nil, completion: @escaping (DataResponse<NSDictionary>, Result<[T]>) -> ()) -> Self {
        let mapperSerializer: DataResponseSerializer<(json: NSDictionary, items: [T])> = DataRequest.objectMapperSerializer(keyPath: keyPath)
        return validate().response(queue: nil, responseSerializer: mapperSerializer, completionHandler: { response in
            if !self.responseWasCanceled(response) {
                let ourResult = response.result.isSuccess ? Result.success(response.result.value!.items) : Result.failure(response.result.error!)
                let result = response.result.isSuccess ? Alamofire.Result.success(response.result.value!.json) : Alamofire.Result.failure(response.result.error!)
                let dataResponse = DataResponse(request: response.request, response: response.response, data: response.data, result: result, timeline: response.timeline)
                completion(dataResponse, ourResult)
            }
        })
    }
    
    public func responseAPIMapArray<T: Mappable>(completion: @escaping (DataResponse<NSArray>, Result<[T]>) -> ()) -> Self {
        let mapperSerializer: DataResponseSerializer<(json: NSArray, items: [T])> = DataRequest.objectMapperSerializer()
        return validate().response(queue: nil, responseSerializer: mapperSerializer, completionHandler: { response in
            if !self.responseWasCanceled(response) {
                let ourResult = response.result.isSuccess ? Result.success(response.result.value!.items) : Result.failure(response.result.error!)
                let result = response.result.isSuccess ? Alamofire.Result.success(response.result.value!.json) : Alamofire.Result.failure(response.result.error!)
                let dataResponse = DataResponse(request: response.request, response: response.response, data: response.data, result: result, timeline: response.timeline)
                completion(dataResponse, ourResult)
            }
        })
    }
    
    public static func objectMapperSerializer<T: Mappable>(keyPath: String? = nil) -> DataResponseSerializer<(json: NSDictionary, item: T)> {
        return DataResponseSerializer { request, response, data, error in
            let serializer: DataResponseSerializer<NSDictionary> = apiErrorResponseSerializer()
            let result = serializer.serializeResponse(request, response, data, error)
            guard result.error == nil else {
                return .failure(result.error!)
            }
            
            var JSONToMap: Any? = result.value
            if let keyPath = keyPath, keyPath.isEmpty == false {
                JSONToMap = result.value?.value(forKeyPath: keyPath)
            }
            
            if let parsedObject = Mapper<T>().map(JSONObject: JSONToMap) {
                return .success((json: result.value!, item: parsedObject) as (json: NSDictionary, item: T))
            }
            
            let failureReason = "ObjectMapper failed to serialize response."
            let error = NSError(domain: APISettings.errorDomain, code: 12313, userInfo: [NSLocalizedDescriptionKey: failureReason])
            return .failure(error)
        }
    }
    
    public static func objectMapperSerializer<T: Mappable>(keyPath: String? = nil) -> DataResponseSerializer<(json: NSDictionary, items: [T])> {
        return DataResponseSerializer { request, response, data, error in
            let serializer: DataResponseSerializer<NSDictionary> = apiErrorResponseSerializer()
            let result = serializer.serializeResponse(request, response, data, error)
            guard result.error == nil else {
                return .failure(result.error!)
            }
            
            var JSONToMap: Any? = result.value
            if let keyPath = keyPath, keyPath.isEmpty == false {
                if keyPath == "*" {
                    JSONToMap = result.value?.allValues
                } else {
                    JSONToMap = result.value?.value(forKeyPath: keyPath)
                }
            }
            
            if let parsedObject = Mapper<T>().mapArray(JSONObject: JSONToMap) {
                return .success((json: result.value!, items: parsedObject) as (json: NSDictionary, items: [T]))
            }
            
            let failureReason = "ObjectMapper failed to serialize response."
            let error = NSError(domain: APISettings.errorDomain, code: 12313, userInfo: [NSLocalizedDescriptionKey: failureReason])
            return .failure(error)
        }
    }
    

    public static func objectMapperSerializer<T: Mappable>() -> DataResponseSerializer<(json: NSArray, items: [T])> {
        return DataResponseSerializer { request, response, data, error in
            let serializer: DataResponseSerializer<NSArray> = apiErrorResponseSerializer()
            let result = serializer.serializeResponse(request, response, data, error)
            guard result.error == nil else {
                return .failure(result.error!)
            }
            
            let JSONToMap: Any? = result.value
            if let parsedObject = Mapper<T>().mapArray(JSONObject: JSONToMap) {
                return .success((json: result.value!, items: parsedObject) as (json: NSArray, items: [T]))
            }
            
            let failureReason = "ObjectMapper failed to serialize response."
            let error = NSError(domain: APISettings.errorDomain, code: 12313, userInfo: [NSLocalizedDescriptionKey: failureReason])
            return .failure(error)
        }
    }
}

extension API {
    class func uploadFile<T: Mappable>(path: String, serverURL: String, parameters: [String : Any]?, headers: [String: String]? = nil,
                          multipart: (data: Data, name: String, fileName: String, mimeType: String),
                          completionHandler: @escaping (DataResponse<NSDictionary>, Result<T>) -> ()) {
        
        uploadFile(path: path, serverURL: serverURL, parameters: parameters, headers:headers, multipart: multipart) { (upload) in
            let _ = upload.responseAPIMap(completion: completionHandler)
        }
    }
}
