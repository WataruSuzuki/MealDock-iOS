//
//  UIViewController+FAB.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/18.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation
import MaterialComponents.MaterialButtons_ColorThemer

extension UIViewController {
    
    func activateFab(fab: MDCFloatingButton, target: Any?, image: UIImage, selector: Selector) {
        fab.setImage(image, for: .normal)
        fab.addTarget(target, action: selector, for: .touchUpInside)
    }
    
    func layout(fab: MDCFloatingButton) {
        if let targetOf = tabBarController?.tabBar {
            fab.autoPinEdge(.trailing, to: .trailing, of: targetOf, withOffset: -30)
            fab.autoPinEdge(.bottom, to: .top, of: targetOf, withOffset: -30)
        } else {
            fab.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -30)
            fab.autoPinEdge(.bottom, to: .top, of: self.view, withOffset: -30)
        }
        view.bringSubview(toFront: fab)
    }

}
