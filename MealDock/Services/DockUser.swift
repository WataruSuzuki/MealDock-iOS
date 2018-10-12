//
//  DockUser.swift
//  MealDock
//
//  Created by Wataru Suzuki 2018/10/16.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import Firebase

class DockUser: NSObject {
    
    let core: User
    private var currentDock: String?
    var dockID: String {
        get {
            if let currentId = currentDock {
                return currentId
            } else {
                return core.uid
            }
        }
    }
    private(set) var usageInfo: UsageInfo?
    private var idAsDock: String?
    var isJoiningSharingGroup: Bool {
        get {
            return idAsDock != nil && idAsDock != core.uid
        }
    }
    var isGroupOwnerMode: Bool {
        get {
            return currentDock == core.uid
        }
    }
    var isPurchased: Bool {
        get {
            guard let info = usageInfo,
                let plan = UsageInfo.PurchasePlan(rawValue: info.purchasePlan) else {
                return false
            }
            debugPrint("plan: \(plan)")
            debugPrint("unlockPremium: \(info.unlockPremium ?? false)")
            debugPrint("unlockedAd: \(info.unlockedAd ?? false)")
            return plan != .free || info.unlockPremium ?? false || info.unlockedAd ?? false
        }
    }
    var switchingDock :((String?) -> Void)?

    init(user: User) {
        self.core = user
        super.init()
        startObserving()
    }
    
    func startObserving() {
        FirebaseService.shared.observeUsageInfo { (info) in
            self.usageInfo = info
            if let usageInfo = self.usageInfo {
                self.currentDock = usageInfo.currentDock
                self.switchingDock?(self.currentDock)
                self.idAsDock = usageInfo.currentID
                if self.isGroupOwnerMode {
                    if let observer = FirebaseService.shared.observers[FirebaseService.ID_PHOTOS] {
                        observer.ref.removeObserver(withHandle: observer.handle)
                        FirebaseService.shared.observers.removeValue(forKey: FirebaseService.ID_PHOTOS)
                    }
                } else {
                    FirebaseService.shared.observePhotosToken(token: { (photoToken) in
                        GooglePhotosService.shared.initSharingAuthState(token: photoToken)
                    })
                    FirebaseService.shared.observePhotosAlbumId(id: { (id) in
                        GooglePhotosService.shared.saveAlbumId(id: id)
                    })
                }
                FirebaseService.shared.usageInfoKVO = "(・w・)b"
                if !self.isPurchased {
                    PurchaseService.shared.confirmPersonalizedConsent(publisherIds: ["your_pub_id"], completion: { (confirmed) in
                        if confirmed {
                            PurchaseService.shared.loadReward(unitId: "your_reward_unit_id")
                        }
                    })
                }
            }
        }
    }
    
    func delete(completion: UserProfileChangeCallback?) {
        core.delete(completion: completion)
    }
    
    func printUserInfo() {
        debugPrint("uid = \(core.uid)")
        debugPrint("displayName = \(String(describing: core.displayName))")
        debugPrint("email = \(String(describing: core.email))")
    }
    
    func hasCapacity(addingSize: Int) -> Bool {
        guard let usage = usageInfo, let plan = UsageInfo.PurchasePlan(rawValue: usage.purchasePlan) else {
            return false
        }
        let counterKeys = FirebaseService.shared.itemCounters.keys
        for key in counterKeys {
            debugPrint(key)
        }
        let counterValues = FirebaseService.shared.itemCounters.values
        for value in counterValues {
            debugPrint(value)
        }
        let currentSize = counterValues.reduce(addingSize, { (num1, num2) -> Int in
            num1 + num2
        })
        debugPrint("currentSize = \(currentSize)")
        return plan.limitSize() > currentSize
    }
}
