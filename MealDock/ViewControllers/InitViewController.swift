//
//  InitViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki 2018/09/14.
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
                    navigationController.title = item.description().localized
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let alert = UIAlertController(title: "m(_ _)m", message: "thank_you_for_using_this_app".localized, preferredStyle: .alert)
        alert.addEmptyOkAction()
        guard let top = UIViewController.currentTop() else { return }
        top.present(alert, animated: true, completion: nil)
    }
    
    static func switchTab(to: TabItem) {
        guard let top = UIViewController.currentTop() else { return }
        if let topTab = top as? InitViewController {
            switchTab(to: to, tabBarController: topTab)
        } else if let tabBarController = top.tabBarController {
            switchTab(to: to, tabBarController: tabBarController)
        } else {
            top.dismiss(animated: true) {
                switchTab(to: to)
            }
        }
    }
    
    private static func switchTab(to: TabItem, tabBarController: UITabBarController) {
        tabBarController.selectedIndex = to.rawValue
        tabBarController.selectedViewController = tabBarController.viewControllers![to.rawValue]
    }

    enum TabItem: Int {
        case dishes = 0,
        inFridgeFoods,
        cartedFoods,
        settings,
        max
    }
}
