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
    
    let firUser: User
    private var currentDock: String?
    var dockID: String {
        get {
            if let currentId = currentDock {
                return currentId
            } else {
                return firUser.uid
            }
        }
    }
    var uid: String { get { return firUser.uid } }
    var displayName: String? {
        get { return firUser.displayName }
    }
    var email: String? { get { return firUser.email } }
    var usageInfo: UsageInfo?
    private var idAsDock: String?
    var isJoiningSharingGroup: Bool {
        get {
            return idAsDock != nil && idAsDock != firUser.uid
        }
    }
    var isGroupOwnerMode: Bool {
        get {
            return currentDock == firUser.uid
        }
    }

    init(user: User) {
        self.firUser = user
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
        firUser.delete(completion: completion)
    }
    
    func printUserInfo() {
        debugPrint("uid = \(firUser.uid)")
        debugPrint("displayName = \(String(describing: firUser.displayName))")
        debugPrint("email = \(String(describing: firUser.email))")
    }
    
}
