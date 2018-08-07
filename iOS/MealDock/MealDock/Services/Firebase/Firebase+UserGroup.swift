//
//  Firebase+User.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/15.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit

extension FirebaseService {

    func createUser() {
        if let user = currentUser {
            self.ref.child("users/\(user.uid)").setValue([
                "username": user.displayName,
                "email": user.email
            ])
        }
    }
    
    func createMyDockGroup() {
        if let user = currentUser {
            self.ref.child("mealdocks").setValue([
                user.uid: "My Dock Group"
                ])
            self.ref.child("users/\(user.uid)/mealdocks").setValue([
                user.uid: "My Dock Group"
            ])
        }
    }
        
    func updatedUserName(username: String) {
        if let user = currentUser {
            self.ref.child("users/\(user.uid)/username").setValue(username)
        }
    }
    
}
