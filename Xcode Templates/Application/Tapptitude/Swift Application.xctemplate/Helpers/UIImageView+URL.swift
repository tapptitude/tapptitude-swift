//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setImageFrom(url: NSURL?, placeholder: UIImage?) {
        self.image = placeholder
        if let url = url {
            self.kf_setImageWithURL(url, placeholderImage: placeholder, optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    
    
    func setImageFromURLString(urlString: String?, placeholder: UIImage?) {
        self.image = placeholder
        if let url = NSURL(string: urlString ?? "") {
            self.kf_setImageWithURL(url, placeholderImage: placeholder, optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        }
    }
}
