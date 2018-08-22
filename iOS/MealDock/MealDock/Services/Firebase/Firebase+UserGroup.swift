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
    
    func deleteCurrentUser() {
        if let user = currentUser {
            deleteMyDockGroup()
            self.ref.child("users/\(user.uid)").removeValue()
            signOut()
        }
    }

    func createMyDockGroup() {
        if let user = currentUser {
            let group = [user.uid: "My Dock Group"]
            self.ref.child("mealdocks").updateChildValues(group)
            self.ref.child("users/\(user.uid)/mealdocks").setValue(group)
        }
    }
    
    func deleteMyDockGroup() {
        if let user = currentUser {
            self.ref.child("users/\(user.uid)/mealdocks").removeValue()
            self.ref.child("mealdocks/\(user.uid)").removeValue()
        }
    }
        
    func updatedUserName(username: String) {
        if let user = currentUser {
            self.ref.child("users/\(user.uid)/username").setValue(username)
        }
    }
    
}
