//
//  FirstViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/07/30.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import FirebaseUI

class FirstViewController: UIViewController,
    FUIAuthDelegate
{
    let providers: [FUIAuthProvider] = [
        FUIGoogleAuth(),
//        FUIFacebookAuth(),
//        FUITwitterAuth(),
//        FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let authUI = FUIAuth.defaultAuthUI() {
            // You need to adopt a FUIAuthDelegate protocol to receive callback
            authUI.delegate = self
            authUI.providers = providers
            let authViewController = authUI.authViewController()
            self.present(authViewController, animated: true, completion: nil)
        }
    }

    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
    }
}

