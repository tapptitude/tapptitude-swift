//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    static func backButtonWithController(_ controller:UIViewController) -> UIBarButtonItem {
        let backButton = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: controller, action: #selector(UIViewController.popViewController))
        backButton.tintColor = UIColorFromRGB(0x959697)
        return backButton
    }
}

extension UIViewController {
    @objc func popViewController() {
        _ = navigationController?.popViewController(animated: true)
    }
}
