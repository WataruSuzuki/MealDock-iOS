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

    func printUserInfo(user: User) {
        debugPrint("uid = \(user.uid)")
        debugPrint("displayName = \(String(describing: user.displayName))")
        debugPrint("email = \(String(describing: user.email))")
    }
    
    func observeUsageInfo(info:((UsageInfo) -> Void)?) {
        if let user = currentUser {
            observeUsageInfo(user: user, info: info)
        } else {
            let handle = observe(\.currentUser) { (user, change) in
                if let newUser = self.currentUser {
                    self.observeUsageInfo(user: newUser, info: info)
                    self.signInObservations["observeUsageInfo"]?.invalidate()
                }
            }
            signInObservations.updateValue(handle, forKey: "observeUsageInfo")
        }
    }
    
    fileprivate func observeUsageInfo(user: User, info:((UsageInfo) -> Void)?) {
        let itemId = FirebaseService.ID_USAGE
        guard observers[itemId] == nil else {
            // Don't duplicate
            return
        }
        let newReference = rootRef.child("\(itemId)/\(user.uid)")
        let newObserver = newReference.observe(.value) { (snapshot) in
            guard let data = snapshot.value! as? [String: Any] else {
                self.InitializedUsageInfo()
                return
            }
            do {
                info?(try FirebaseDecoder().decode(UsageInfo.self, from: data))
            } catch let error {
                print(error)
            }
        }
        observers.updateValue(FirebaseObserver(ref: newReference, handle: newObserver), forKey: itemId)
    }
    
    func InitializedUsageInfo() {
        if let user = currentUser {
            addMyDockGroupMember(memberId: user.uid, name: user.displayName ?? "Dock Owner")
            rootRef.child("\(FirebaseService.ID_USAGE)/\(user.uid)").setValue([
                "sizeOfItems": 100,
                "subscriptionPlan": 0,
                "currentDock": user.uid
                ])
        }
    }
    
    func deleteCurrentUser() {
        if let user = currentUser {
            deleteMyDockGroup()
            rootRef.child("\(FirebaseService.ID_USAGE)/\(user.uid)").removeValue()
            removeAllMyDishes()
            removeAllInFridgeHarvest()
            removeAllCartedHarvest()
            removeAllMarketItems()
            signOut()
            user.delete { (error) in
                if let error = error {
                    print(error)
                }
            }
        }
    }

    func createMyDockGroup() {
    }
    
    func deleteMyDockGroup() {
        if let user = currentUser {
            rootRef.child("\(FirebaseService.ID_USAGE)/\(user.uid)/currentDock").removeValue()
            rootRef.child("\(FirebaseService.ID_MEAL_DOCKS)/\(user.uid)").removeValue()
        }
        A0SimpleKeychain().deleteEntry(forKey: initializedFUIAuth)
        A0SimpleKeychain().deleteEntry(forKey: emailFUIAuth)
        A0SimpleKeychain().deleteEntry(forKey: passwordFUIAuth)
        A0SimpleKeychain().deleteEntry(forKey: usernameFUIAuth)
    }
    
}
