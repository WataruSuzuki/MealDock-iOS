//
//  Firebase+User.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/09/15.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import CodableFirebase

extension FirebaseService {

    func observeUsageInfo(info:((UsageInfo) -> Void)?) {
        waitSignIn {
            self.observeUsageInfo(user: self.currentUser!, info: info)
        }
    }
    
    fileprivate func observeUsageInfo(user: DockUser, info:((UsageInfo) -> Void)?) {
        let itemId = FirebaseService.ID_USAGE
        guard observers[itemId] == nil else {
            // Don't duplicate
            return
        }
        let newReference = rootRef.child("\(itemId)/\(user.core.uid)")
        let newObserver = newReference.observe(.value) { (snapshot) in
            guard let data = snapshot.value! as? [String: Any] else {
                debugPrint(snapshot)
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
            addMyDockGroupMember(memberId: user.core.uid, name: user.core.displayName ?? "Dock Owner")
            rootRef.child("\(FirebaseService.ID_USAGE)/\(user.core.uid)").setValue([
                "purchasePlan": UsageInfo.PurchasePlan.free.rawValue
                ])
            joinToGroupDock(dock: user.core.uid, id: user.core.uid)
        }
    }
    
    func updateUnlockAdInfo(unlock: Bool) {
        if let user = currentUser {
            rootRef.child("\(FirebaseService.ID_USAGE)/\(user.core.uid)/unlockedAd").setValue(unlock)
        }
    }
    
    func updateUnlockPremiumInfo(unlock: Bool) {
        if let user = currentUser {
            rootRef.child("\(FirebaseService.ID_USAGE)/\(user.core.uid)/unlockPremium").setValue(unlock)
        }
    }
    
    func updateSubscriptionPlanInfo(plan: UsageInfo.PurchasePlan, expiryDate: TimeInterval?) {
        if let user = currentUser {
            if let date = expiryDate {
                rootRef.child("\(FirebaseService.ID_USAGE)/\(user.core.uid)/expireDate").setValue(date)
                rootRef.child("\(FirebaseService.ID_USAGE)/\(user.core.uid)/purchasePlan").setValue(plan.rawValue)
            } else {
                rootRef.child("\(FirebaseService.ID_USAGE)/\(user.core.uid)/purchasePlan").setValue(UsageInfo.PurchasePlan.free.rawValue)
            }
        }
    }
    
    func deleteUsageInfo() {
        if let user = currentUser {
            rootRef.child("\(FirebaseService.ID_USAGE)/\(user.core.uid)").removeValue()
        }
    }
    
    func deleteCurrentUser() {
        if let user = currentUser {
            deleteUsageInfo()
            removeAllMyDishes()
            removeAllInFridgeHarvest()
            removeAllCartedHarvest()
            removeAllMarketItems()
            deleteMyDockGroup()
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
            rootRef.child("\(FirebaseService.ID_USAGE)/\(user.core.uid)/currentDock").removeValue()
            rootRef.child("\(FirebaseService.ID_MEAL_DOCKS)/\(user.core.uid)").removeValue()
        }
    }
    
    func updateProfile(displayName: String) {
        if let user = currentUser {
            let request = user.core.createProfileChangeRequest()
            request.displayName = displayName
            request.commitChanges { (error) in
                self.handleResult(funcName: #function, error: error)
            }
        }
    }
    
    func sendPasswordReset() {
        if let auth = defaultAuthUI.auth, let email = currentUser?.core.email {
            auth.sendPasswordReset(withEmail: email) { (error) in
                self.handleResult(funcName: #function, error: error)
            }
        }
    }
    
    func updateEmail(newEmail: String) {
        if let user = currentUser {
            user.core.updateEmail(to: newEmail) { (error) in
                self.handleResult(funcName: #function, error: error)
            }
        }
    }
    
    private func handleResult(funcName: String, error: Error?) {
        guard error == nil else {
            self.handleError(error: error, funcName: funcName)
            return
        }
        UIViewController.snackBarMessage(text: NSLocalizedString("receive_your_change_request", comment: ""))
    }
}
