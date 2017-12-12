//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

struct User: Codable {
    var userID : String!
    
    var firstName : String?
    var lastName : String?
    
    var fullName: String {
        return "\(firstName ?? "") \(lastName ?? "")"
    }
}


struct LoginSession: Decodable {
    var driver: User
    var token: String
    
    enum CodingKeys: String, CodingKey {
        case driver
        case token = "auth_key"
    }
}

