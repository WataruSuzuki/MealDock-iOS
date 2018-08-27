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

    func observeUsageInfo(info:((UsageInfo) -> Void)?) {
        if let user = currentUser {
            observeUsageInfo(user: user, info: info)
        } else {
            let kvo = observe(\.currentUser) { (user, change) in
                if let newUser = self.currentUser {
                    self.observeUsageInfo(user: newUser, info: info)
                    self.signInObservations["observeUsageInfo"]?.invalidate()
                }
            }
            signInObservations.updateValue(kvo, forKey: "observeUsageInfo")
        }
    }
    
    fileprivate func observeUsageInfo(user: DockUser, info:((UsageInfo) -> Void)?) {
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
            addMyDockGroupMember(memberId: user.uid, name: user.core.displayName ?? "Dock Owner")
            rootRef.child("\(FirebaseService.ID_USAGE)/\(user.uid)").setValue([
                "purchasePlan": UsageInfo.PurchasePlan.free.rawValue,
                "currentDock": user.uid
                ])
        }
    }
    
    func updateUnlockAdInfo(unlock: Bool) {
        if let user = currentUser {
            rootRef.child("\(FirebaseService.ID_USAGE)/\(user.uid)/unlockedAd").setValue(unlock)
            updateSubscriptionPlanInfo(plan: (unlock ? .unlockAd : .free), expiryDate: nil)
        }
    }
    
    func updateSubscriptionPlanInfo(plan: UsageInfo.PurchasePlan, expiryDate: TimeInterval?) {
        if let user = currentUser {
            if let date = expiryDate {
                rootRef.child("\(FirebaseService.ID_USAGE)/\(user.uid)/expireDate").setValue(date)
                rootRef.child("\(FirebaseService.ID_USAGE)/\(user.uid)/purchasePlan").setValue(plan.rawValue)
            } else if let unlockAd = user.usageInfo?.unlockedAd, unlockAd {
                rootRef.child("\(FirebaseService.ID_USAGE)/\(user.uid)/purchasePlan").setValue(UsageInfo.PurchasePlan.unlockAd.rawValue)
            } else {
                rootRef.child("\(FirebaseService.ID_USAGE)/\(user.uid)/purchasePlan").setValue(UsageInfo.PurchasePlan.free.rawValue)
            }
        }
    }
    
    func deleteUsageInfo() {
        if let user = currentUser {
            rootRef.child("\(FirebaseService.ID_USAGE)/\(user.uid)").removeValue()
        }
    }
    
    func deleteCurrentUser() {
        if let user = currentUser {
            deleteMyDockGroup()
            deleteUsageInfo()
            removeAllMyDishes()
            removeAllInFridgeHarvest()
            removeAllCartedHarvest()
            removeAllMarketItems()
            user.delete { (error) in
                self.handleError(error: error, funcName: #function)
            }
            A0SimpleKeychain().deleteEntry(forKey: initializedFUIAuth)
            A0SimpleKeychain().deleteEntry(forKey: emailFUIAuth)
            A0SimpleKeychain().deleteEntry(forKey: passwordFUIAuth)
            A0SimpleKeychain().deleteEntry(forKey: usernameFUIAuth)
        }
    }

    func deleteMyDockGroup() {
        if let user = currentUser {
            rootRef.child("\(FirebaseService.ID_USAGE)/\(user.uid)/currentDock").removeValue()
            rootRef.child("\(FirebaseService.ID_MEAL_DOCKS)/\(user.uid)").removeValue()
        }
    }
    
    func updateProfile(displayName: String) {
        if let user = currentUser {
            let request = user.core.createProfileChangeRequest()
            request.displayName = displayName
            request.commitChanges { (error) in
                self.handleError(error: error, funcName: #function)
            }
        }
    }
    
    func sendPasswordReset() {
        if let auth = defaultAuthUI.auth, let email = currentUser?.email {
            auth.sendPasswordReset(withEmail: email) { (error) in
                self.handleError(error: error, funcName: #function)
            }
        }
    }
    
    func updateEmail(newEmail: String) {
        if let user = currentUser {
            user.core.updateEmail(to: newEmail) { (error) in
                self.handleError(error: error, funcName: #function)
            }
        }
    }
}
