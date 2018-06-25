//
//  FirebaseService.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/09/14.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class FirebaseService: NSObject,
    FUIAuthDelegate
{
    
    let providers: [FUIAuthProvider] = [
        FUIGoogleAuth(),
//        FUIFacebookAuth(),
//        FUITwitterAuth(),
//        FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()),
    ]
    
    var defaultAuthUI: FUIAuth!
    var currentUser: User?
    var isSignOn = false
    
    override init() {
        super.init()
        FirebaseApp.configure()
        FUIPasswordSignInViewController.switchMethodInjection()

        loadDefaultAuthUI()
    }
    
    fileprivate func loadDefaultAuthUI() {
        if let authUI = FUIAuth.defaultAuthUI() {
            // You need to adopt a FUIAuthDelegate protocol to receive callback
            authUI.delegate = self
            authUI.providers = providers
            
            defaultAuthUI = authUI
        }
    }
    
    func requestAuthUI(vc: UIViewController) {
        if let authUI = defaultAuthUI {
            let authViewController = authUI.authViewController()
            vc.present(authViewController, animated: true, completion: nil)
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            currentUser = user
            isSignOn = true
        } else {
            do {
                try authUI.signOut()
                isSignOn = false
            } catch {
                // エラー処理
            }
        }
    }
    
    class func isSourceApplication(url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        return false
    }
    
}
