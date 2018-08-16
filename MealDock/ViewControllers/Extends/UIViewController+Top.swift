//
//  UIViewController+Top.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/17.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func currentTop() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}
