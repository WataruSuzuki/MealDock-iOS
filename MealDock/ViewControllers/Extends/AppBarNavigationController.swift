//
//  AppBarNavigationController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/17.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialAppBar
import MaterialComponents.MaterialPalettes

class AppBarNavigationController: MDCAppBarNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: MDCAppBarNavigationControllerDelegate
    
    func appBarNavigationController(_ navigationController: MDCAppBarNavigationController,
                                    willAdd appBarViewController: MDCAppBarViewController,
                                    asChildOf viewController: UIViewController) {
        appBarViewController.headerView.backgroundColor = MDCPalette.cyan.tint300
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
