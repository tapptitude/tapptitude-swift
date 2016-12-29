//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import ObjectMapper

final class User {
    var userID : String!
    
    var firstName : String?
    var lastName : String?
    
    var fullName: String {
        return "\(firstName ?? "") \(lastName ?? "")"
    }
}

extension User: Mappable {
    convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        userID <- map["_id"]
        lastName <- map["lastName"]
        firstName <- map["firstName"]
    }
}
