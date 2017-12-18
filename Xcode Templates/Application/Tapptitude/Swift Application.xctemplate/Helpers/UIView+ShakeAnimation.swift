//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

extension UIView {
    func shakeAnimation() {
        let translation: CGFloat = 6.5
        let shake = CABasicAnimation(keyPath: "transform")
        shake.duration = 0.05
        shake.autoreverses = true
        shake.repeatCount = MAXFLOAT
        shake.isRemovedOnCompletion = false
    
        shake.fromValue = NSValue(caTransform3D: CATransform3DTranslate(self.layer.transform, -translation, 0, 0))
        shake.toValue = NSValue(caTransform3D: CATransform3DTranslate(self.layer.transform, translation, 0, 0))
        self.layer.add(shake, forKey: "shakeAnimation")
        
        DispatchQueue.main.after(seconds: 0.15) {
            self.layer.removeAnimation(forKey: "shakeAnimation")
        }
    }
}
