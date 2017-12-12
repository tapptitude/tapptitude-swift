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
    func setImageFrom(_ url: URL?, placeholder: UIImage?) {
        self.image = placeholder
        if let url = url {
            self.kf.setImage(with: url, placeholder: placeholder, options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    
    
    func setImageFromURLString(_ urlString: String?, placeholder: UIImage?) {
        self.image = placeholder
        if let url = URL(string: urlString ?? "") {
            self.kf.setImage(with: url, placeholder: placeholder, options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
}

