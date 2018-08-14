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
    
    private let user: User
    private var currentDock: String?
    var dockID: String {
        get {
            if let currentId = currentDock {
                return currentId
            } else {
                return user.uid
            }
        }
    }
    var uid: String { get { return user.uid } }
    var displayName: String? {
        get { return user.displayName }
    }
    var usageInfo: UsageInfo?
    private var idAsDock: String?
    var isJoiningSharingGroup: Bool {
        get {
            return idAsDock != nil && idAsDock != user.uid
        }
    }
    var isGroupOwnerMode: Bool {
        get {
            return currentDock == user.uid
        }
    }

    init(user: User) {
        self.user = user
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
        user.delete(completion: completion)
    }
    
    func printUserInfo() {
        debugPrint("uid = \(user.uid)")
        debugPrint("displayName = \(String(describing: user.displayName))")
        debugPrint("email = \(String(describing: user.email))")
    }
    
}
