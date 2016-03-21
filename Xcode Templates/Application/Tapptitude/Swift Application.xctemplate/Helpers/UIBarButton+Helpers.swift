//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    static func backButtonWithController(controller:UIViewController) -> UIBarButtonItem {
        let image = UIImage(named:"back_arrow")?.imageWithRenderingMode(.AlwaysOriginal)
        let barButton = UIBarButtonItem(image: image, landscapeImagePhone: nil, style: .Plain, target: controller, action: Selector("popViewController"))
        return barButton
    }
}

extension UIViewController {
    func popViewController() {
        navigationController?.popViewControllerAnimated(true)
    }
}
