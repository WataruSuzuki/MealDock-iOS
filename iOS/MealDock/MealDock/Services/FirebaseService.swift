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
import SimpleKeychain

class FirebaseService: NSObject,
    FUIAuthDelegate
{
    static let shared: FirebaseService = {
        return FirebaseService()
    }()
    
    let providers: [FUIAuthProvider] = [
//        FUIGoogleAuth(),
//        FUIFacebookAuth(),
//        FUITwitterAuth(),
//        FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()),
    ]
    
    var defaultAuthUI: FUIAuth!
    var currentUser: User?
    var handle: AuthStateDidChangeListenerHandle!
    var state: State
    var isSignOn: Bool {
        get {
            return currentUser != nil
        }
    }
    
    private override init() {
        state = .unknown
        FirebaseApp.configure()
        FUIPasswordSignInViewController.switchMethodInjection()
        
        super.init()
        loadDefaultAuthUI()
    }
    
    fileprivate func loadDefaultAuthUI() {
        if let authUI = FUIAuth.defaultAuthUI() {
            // You need to adopt a FUIAuthDelegate protocol to receive callback
            authUI.delegate = self
            authUI.providers = providers
            
            defaultAuthUI = authUI
            signInByKeychain()
        }
    }
    
    fileprivate func regsiterStateListener() {
        if handle == nil {
            handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                print("auth = \(auth)")
                if let user = user {
                    print("user = \(user.debugDescription)")
                } else {
                    self.fetchAuth()
                }
            }
        }
    }
    
    fileprivate func signInByKeychain() {
        if let email = A0SimpleKeychain().string(forKey: emailFUIAuth),
            let password = A0SimpleKeychain().string(forKey: passwordFUIAuth) {
            signIn(byEmail: email, password: password)
        } else {
            regsiterStateListener()
        }
    }
    
    fileprivate func signIn(byEmail email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error)
            } else {
                self.currentUser = result?.user
            }
            self.regsiterStateListener()
        }
    }
    
    func fetchAuth() {
        if let authUI = defaultAuthUI {
            let authViewController = authUI.authViewController()
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                if let controller = delegate.window?.rootViewController {
                    controller.present(authViewController, animated: true, completion: nil)
                }
            }
        }
    }
    

    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            currentUser = user
        } else {
            print(error?.localizedDescription ?? "error")
            signOut(authUI)
        }
    }
    
    fileprivate func signOut(_ authUI: FUIAuth) {
        do {
            try authUI.signOut()
        } catch (let error) {
            print(error)
        }
    }
    
    func isSourceApplication(url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        return defaultAuthUI.handleOpen(url, sourceApplication: sourceApplication)
    }
    
    enum State: Int {
        case unknown = 0,
        signing,
        signOn,
        signOff
    }
}
