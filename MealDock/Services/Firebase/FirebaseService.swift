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
    
    static let ID_MARKET_ITEMS = "market_items"
    static let ID_CARTED_ITEMS = "carted_items"
    static let ID_FRIDGE_ITEMS = "in_fridge_items"
    static let ID_DISH_ITEMS = "dishes"
    static let ID_MEAL_DOCKS = "mealdocks"
    static let ID_USAGE = "usage"

    let providers: [FUIAuthProvider] = [
//        FUIGoogleAuth(),
//        FUIFacebookAuth(),
//        FUITwitterAuth(),
//        FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()),
    ]
    
    var defaultAuthUI: FUIAuth!
    @objc dynamic var currentUser: User?
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle!
    var database: Database!
    var rootRef: DatabaseReference!
    var connectedRef: DatabaseReference!
    var presenceRef: DatabaseReference!
    var storage: Storage!
    var storageRef: StorageReference!
    var isSignOn: Bool {
        get {
            return currentUser != nil
        }
    }
    var signInObservations = [String: NSKeyValueObservation]()
    var observers = [String: FirebaseObserver]()
    //var harvests = initHarvestArray()
    var usageInfo: UsageInfo?

    class func initHarvestArray() -> [[Harvest]] {
        return [[Harvest]](repeating: [], count: Harvest.Section.max.rawValue)
    }
    
    private override init() {
        FirebaseApp.configure()
        FirebaseUIAuthInjection.kakushiAzi()
        
        super.init()
        regsiterAuthStateListener()
        loadDefaultAuthUI()
        
        Database.database().isPersistenceEnabled = true
        database = Database.database()
        rootRef = database.reference()
        startToObservingDatabase()
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
    
    fileprivate func regsiterAuthStateListener() {
        if authStateDidChangeListenerHandle == nil {
            authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
                debugPrint("auth = \(auth.debugDescription)")
                self.currentUser = user
                if let user = self.currentUser {
                    self.printUserInfo(user: user)
                } else {
                    self.requestAuthUI()
                }
            }
        }
    }
    
    fileprivate func startToObservingDatabase() {
        observeReachability()
        observeUsageInfo { (info) in
            self.usageInfo = info
        }
    }
    
    fileprivate func signInByKeychain() {
        if let email = A0SimpleKeychain().string(forKey: emailFUIAuth),
            let password = A0SimpleKeychain().string(forKey: passwordFUIAuth) {
            signIn(byEmail: email, password: password)
        }
    }
    
    fileprivate func signIn(byEmail email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error)
            }
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
        if let error = error {
            print(error)
            signOut(authUI)
        }
    }
    
    func signOut() {
        if let authUI = defaultAuthUI {
            signOut(authUI)
        }
        GooglePhotosService.removeAuthStatus()
    }
    
    fileprivate func signOut(_ authUI: FUIAuth) {
        do {
            try authUI.signOut()
            currentUser = nil
        } catch (let error) {
            print(error)
        }
    }
    
    func clearAllObservers() {
        let observerValues = [FirebaseObserver](observers.values)
        for observer in observerValues {
            observer.ref.removeObserver(withHandle: observer.handle)
        }
    }
    
    func isSourceApplication(url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        return defaultAuthUI.handleOpen(url, sourceApplication: sourceApplication)
    }
    
}
