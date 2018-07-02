//
//  Firebase+User.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/15.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit

extension FirebaseService {

    func addUser() {
        if let user = currentUser {
            self.ref.child("users").child(user.uid).setValue(["username": "username"])
        }
    }
    
    func updatedUserName(username: String) {
        if let user = currentUser {
            self.ref.child("users/\(user.uid)/username").setValue(username)
        }
    }
}
