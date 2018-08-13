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
    private var currentDockId: String?
    var dockID: String {
        get {
            if let currentId = currentDockId {
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
    
    init(user: User) {
        self.user = user
    }
    
    func delete(completion: UserProfileChangeCallback?) {
        user.delete(completion: completion)
    }
    
    func printUserInfo() {
        debugPrint("uid = \(user.uid)")
        debugPrint("displayName = \(String(describing: user.displayName))")
        debugPrint("email = \(String(describing: user.email))")
    }
    
}
