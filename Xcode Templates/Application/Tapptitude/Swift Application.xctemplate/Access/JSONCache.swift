//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import ObjectMapper

/// Usage Ex:
/// - loading -- `lazy var creditCards: [CreditCard]? = JSONCache.creditCards.loadFromFile()`
/// - saving -- `JSONCache.creditCards.saveToFile(cards)`
enum JSONCache {
    
//    static var bookingHistory: MapperCaching<[Booking]> {
//        return userResource()
//    }
//    
//    static var community: MapperCaching<[Post]> {
//        return resource()
//    }
    
    static func clearAllSavedResource() {
        MapperCaching<Any>.deleteCachingDirectory()
    }
}

extension JSONCache {
    fileprivate static func userResourceID(function: String = #function) -> String {
        let id = Session.currentUserID ?? ""
        return function + "_" + id
    }
    
    fileprivate static func userResource<T>(function: String = #function) -> MapperCaching<T> {
        return MapperCaching(resourceID: userResourceID(function: function))
    }
    
    fileprivate static func resource<T>(function: String = #function) -> MapperCaching<T> {
        return MapperCaching(resourceID: function)
    }
}
