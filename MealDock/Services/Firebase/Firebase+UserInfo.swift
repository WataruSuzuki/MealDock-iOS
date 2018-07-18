//
//  Firebase+User.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/15.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import CodableFirebase

extension FirebaseService {

    func printUserInfo() {
        if let user = currentUser {
            print("uid = \(user.uid)")
            print("displayName = \(String(describing: user.displayName))")
            print("email = \(String(describing: user.email))")
        }
    }
    
    func observeUserInfo(info:((UserInfo) -> Void)?) {
        if let user = currentUser {
            observeUserInfo(user: user, info: info)
        } else {
            let handle = observe(\.currentUser) { (user, change) in
                self.observeUserInfo(user: self.currentUser!, info: info)
                self.signInObservations["observeUserInfo"]?.invalidate()
            }
            signInObservations.updateValue(handle, forKey: "observeUserInfo")
        }
    }
    
    fileprivate func observeUserInfo(user: User, info:((UserInfo) -> Void)?) {
        ref.child("users/\(user.uid)").observe(.value) { (snapshot) in
            if let data = snapshot.value! as? [String: Any] {
                do {
                    info?(try FirebaseDecoder().decode(UserInfo.self, from: data))
                } catch let error {
                    print(error)
                }
            }
        }
    }
    
    func updatedStorageUserInfo(value: Int) {
        if let user = currentUser {
            ref.child("users/\(user.uid)/storage").setValue(value)
        }
    }
    
    func createUserInfo() {
        if let user = currentUser {
            ref.child("users/\(user.uid)").setValue([
                "username": user.displayName,
                "email": user.email
            ])
        }
    }
    
    func deleteCurrentUser() {
        if let user = currentUser {
            deleteMyDockGroup()
            ref.child("users/\(user.uid)").removeValue()
            removeAllMyDishes()
            signOut()
        }
    }

    func createMyDockGroup() {
        if let user = currentUser {
            let group = [user.uid: "My Dock Group"]
            ref.child("mealdocks").updateChildValues(group)
            ref.child("users/\(user.uid)/mealdocks").setValue(group)
        }
    }
    
    func deleteMyDockGroup() {
        if let user = currentUser {
            ref.child("users/\(user.uid)/mealdocks").removeValue()
            ref.child("mealdocks/\(user.uid)").removeValue()
        }
        A0SimpleKeychain().deleteEntry(forKey: initializedFUIAuth)
        A0SimpleKeychain().deleteEntry(forKey: emailFUIAuth)
        A0SimpleKeychain().deleteEntry(forKey: passwordFUIAuth)
        A0SimpleKeychain().deleteEntry(forKey: usernameFUIAuth)
    }
        
    func updatedUserName(username: String) {
        if let user = currentUser {
            ref.child("users/\(user.uid)/username").setValue(username)
        }
    }
    
}
