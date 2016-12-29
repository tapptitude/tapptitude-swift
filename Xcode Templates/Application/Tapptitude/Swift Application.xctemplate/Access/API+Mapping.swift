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

extension DataRequest {
    public func responseAPIMap<T: Mappable>(keyPath: String? = nil, completion: @escaping (DataResponse<NSDictionary>, T?) -> ()) -> Self {
        let mapperSerializer: DataResponseSerializer<(json: NSDictionary, item: T)> = DataRequest.objectMapperSerializer(keyPath: keyPath)
        return validate().response(queue: nil, responseSerializer: mapperSerializer, completionHandler: { response in
            if !self.responseWasCanceled(response) {
                let result = response.result.isSuccess ? Result.success(response.result.value!.json) : Result.failure(response.result.error!)
                let dataResponse = DataResponse(request: response.request, response: response.response, data: response.data, result: result, timeline: response.timeline)
                completion(dataResponse, response.result.value?.item)
            }
        })
    }
    
    public func responseAPIMap<T: Mappable>(keyPath: String? = nil, completion: @escaping (DataResponse<NSDictionary>, [T]?) -> ()) -> Self {
        let mapperSerializer: DataResponseSerializer<(json: NSDictionary, items: [T])> = DataRequest.objectMapperSerializer(keyPath: keyPath)
        return validate().response(queue: nil, responseSerializer: mapperSerializer, completionHandler: { response in
            if !self.responseWasCanceled(response) {
                let result = response.result.isSuccess ? Result.success(response.result.value!.json) : Result.failure(response.result.error!)
                let dataResponse = DataResponse(request: response.request, response: response.response, data: response.data, result: result, timeline: response.timeline)
                completion(dataResponse, response.result.value?.items)
            }
        })
    }
    
    public static func objectMapperSerializer<T: Mappable>(keyPath: String? = nil) -> DataResponseSerializer<(json: NSDictionary, item: T)> {
        return DataResponseSerializer { request, response, data, error in
            let result = apiErrorResponseSerializer().serializeResponse(request, response, data, error)
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
            let result = apiErrorResponseSerializer().serializeResponse(request, response, data, error)
            guard result.error == nil else {
                return .failure(result.error!)
            }
            
            var JSONToMap: Any? = result.value
            if let keyPath = keyPath, keyPath.isEmpty == false {
                JSONToMap = result.value?.value(forKeyPath: keyPath)
            }
            
            if let parsedObject = Mapper<T>().mapArray(JSONObject: JSONToMap) {
                return .success((json: result.value!, items: parsedObject) as (json: NSDictionary, items: [T]))
            }
            
            let failureReason = "ObjectMapper failed to serialize response."
            let error = NSError(domain: APISettings.errorDomain, code: 12313, userInfo: [NSLocalizedDescriptionKey: failureReason])
            return .failure(error)
        }
        
    }
}
