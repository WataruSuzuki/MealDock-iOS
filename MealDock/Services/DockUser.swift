//
//  DockUser.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/16.
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
    var uid: String { get { return core.uid } }
    var email: String? { get { return core.email } }
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
            }
        }
    }
    var switchingDock :((String?) -> Void)?
    
    func delete(completion: UserProfileChangeCallback?) {
        core.delete(completion: completion)
    }
    
    func printUserInfo() {
        debugPrint("uid = \(core.uid)")
        debugPrint("displayName = \(String(describing: core.displayName))")
        debugPrint("email = \(String(describing: core.email))")
    }
    
    func hasCapacity(addingSize: Int) -> Bool {
        guard let usage = usageInfo else {
            return false
        }
        let counters = FirebaseService.shared.itemCounters.values
        return usage.sizeOfItems > counters.reduce(addingSize, { (num1, num2) -> Int in
            num1 + num2
        })
    }
}
