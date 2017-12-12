//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

/// Usage Ex:
/// - loading -- `lazy var creditCards: [CreditCard]? = JSONCache.creditCards.loadFromFile()`
/// - saving -- `JSONCache.creditCards.saveToFile(cards)`
enum JSONCache {
    
//    static var bookingHistory: CodableCaching<[Booking]> {
//        return userResource()
//    }
//
//    static var community: CodableCaching<[Post]> {
//        return resource()
//    }
    
    static var currentUser: CodableCaching<User> {
        return resource()
    }
    
    static func clearAllSavedResource() {
        CodableCaching<Any>.deleteCachingDirectory()
    }
}

extension JSONCache {
    fileprivate static func userResourceID(function: String = #function) -> String {
        let id = Session.currentUserID ?? ""
        return function + "_" + id
    }
    
    fileprivate static func userResource<T>(function: String = #function) -> CodableCaching<T> {
        return CodableCaching(resourceID: userResourceID(function: function))
    }
    
    fileprivate static func resource<T>(function: String = #function) -> CodableCaching<T> {
        return CodableCaching(resourceID: function)
    }
}

