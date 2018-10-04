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
import FirebaseDatabase
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
    static let ID_PHOTOS = "photos"

    let providers: [FUIAuthProvider] = [
//        FUIGoogleAuth(),
//        FUIFacebookAuth(),
//        FUITwitterAuth(),
//        FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()),
    ]
    
    var defaultAuthUI: FUIAuth!
    @objc dynamic var currentUser: DockUser?
    @objc dynamic var usageInfoKVO: NSString?
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle!
    var database: Database!
    var rootRef: DatabaseReference!
    var connectedRef: DatabaseReference!
    var presenceRef: DatabaseReference!
    //var storage: Storage!
    //var storageRef: StorageReference!
    var isSignOn: Bool {
        get {
            return currentUser != nil
        }
    }
    var signInObservations = [String: NSKeyValueObservation]()
    var observers = [String: FirebaseObserver]()
    var itemCounters = [String : Int]()

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
    
    func waitSignIn(completion: @escaping (()->Void)) {
        guard currentUser == nil else {
            completion()
            return
        }
        let kvo = observe(\.currentUser) { (value, change) in
            completion()
            self.signInObservations["waitSignIn"]?.invalidate()
        }
        signInObservations.updateValue(kvo, forKey: "waitSignIn")
    }
    
    func waitLoadUserInfo(completed: @escaping (()->Void)) {
        guard usageInfoKVO == nil else {
            completed()
            return
        }
        let kvo = observe(\.usageInfoKVO) { (value, change) in
            completed()
            self.signInObservations["waitSignInProcess"]?.invalidate()
        }
        signInObservations.updateValue(kvo, forKey: "waitSignInProcess")
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
            let indicator = UIViewController.topIndicatorStart()
            authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
                debugPrint("auth = \(auth.debugDescription)")
                if let indicator = indicator {
                    UIViewController.topIndicatorStop(view: indicator)
                }
                if let user = user {
                    self.currentUser = DockUser(user: user)
                } else {
                    self.currentUser = nil
                    self.requestAuthUI()
                }
                self.currentUser?.printUserInfo()
            }
        }
    }
    
    fileprivate func startToObservingDatabase() {
        observeReachability()
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
        GooglePhotosService.shared.removeAuthStatus()
    }
    
    fileprivate func signOut(_ authUI: FUIAuth) {
        do {
            try authUI.signOut()
            currentUser = nil
            clearAllObservers(evenUserInfo: true)
            itemCounters.removeAll()
        } catch (let error) {
            print(error)
        }
    }
    
    func clearAllObservers(evenUserInfo: Bool) {
        var userInfoObserver: FirebaseObserver?
        if !evenUserInfo {
            userInfoObserver = observers[FirebaseService.ID_USAGE]
            observers.removeValue(forKey: FirebaseService.ID_USAGE)
        }
        let observerValues = [FirebaseObserver](observers.values)
        for observer in observerValues {
            observer.ref.removeObserver(withHandle: observer.handle)
        }
        observers.removeAll()
        if let temp = userInfoObserver {
            observers.updateValue(temp, forKey: FirebaseService.ID_USAGE)
        }
    }
    
    func isSourceApplication(url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        return defaultAuthUI.handleOpen(url, sourceApplication: sourceApplication)
    }
    
}
