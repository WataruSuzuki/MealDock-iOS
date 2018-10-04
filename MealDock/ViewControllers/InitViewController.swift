//
//  InitViewController.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/09/14.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import FirebaseUI

class InitViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let tabbars = viewControllers {
            for (index, tab) in tabbars.enumerated() {
                if let item = TabItem(rawValue: index), let navigationController = tab as? UINavigationController {
                    navigationController.title = NSLocalizedString(item.description(), comment: "")
                }
            }
        }
    }

    enum TabItem: Int {
        case dishes = 0,
        inFridgeFoods,
        cartedFoods,
        settings,
        max
    }
}
