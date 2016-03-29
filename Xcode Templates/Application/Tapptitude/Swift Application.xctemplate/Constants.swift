//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

struct Constants {
    #if RELEASE
    static let API_URL = "your api url"
    static let API_KEY = "your api key"
    #elseif DEBUG
    static let API_URL = "your api url"
    static let API_KEY = "your api key"
    #endif
}
