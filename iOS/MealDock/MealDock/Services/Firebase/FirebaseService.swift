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
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle!
    var database: Database!
    var ref: DatabaseReference!
    var connectedRef: DatabaseReference!
    var presenceRef: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    var isSignOn: Bool {
        get {
            return currentUser != nil
        }
    }
    //var harvests = [Harvest]()
    var harvests = [[Harvest]](repeating: [], count: Harvest.Section.max.rawValue)

    private override init() {
        FirebaseApp.configure()
        FirebaseUIAuthInjection.kakushiAzi()
        
        super.init()
        loadDefaultAuthUI()
        
        Database.database().isPersistenceEnabled = true
        database = Database.database()
        ref = database.reference()
        observeReachability()
        observeDatabaseHandle()
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
        if authStateDidChangeListenerHandle == nil {
            authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
                print("auth = \(auth)")
                self.currentUser = user
                if let user = self.currentUser {
                    print("user = \(user)")
                } else {
                    self.requestAuthUI()
                }
            }
        }
    }
    
    fileprivate func observeDatabaseHandle() {
        databaseHandle = ref.observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as! [String : AnyObject]
            print("ovserveDatabaseHandle = \(value)")
        })
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
    
    func requestAuthUI() {
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
    
    func signOut() {
        if let authUI = defaultAuthUI {
            signOut(authUI)
        }
    }
    
    fileprivate func signOut(_ authUI: FUIAuth) {
        do {
            try authUI.signOut()
            currentUser = nil
        } catch (let error) {
            print(error)
        }
    }
    
    func isSourceApplication(url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        return defaultAuthUI.handleOpen(url, sourceApplication: sourceApplication)
    }
    
}
