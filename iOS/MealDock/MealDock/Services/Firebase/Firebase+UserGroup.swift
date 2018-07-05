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
            self.ref.child("users").child(user.uid).setValue([
                "username": user.displayName,
                "email": user.email
            ])
        }
    }
    
    func readInfo() {
        if let user = currentUser {
            self.ref.child("messages")
                .child(user.uid)//ここを指定しないとパーミッションによってはエラーになる
                //.child("message from \(String(describing: user.displayName))")
                .observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
            }) { (error) in
                print(error.localizedDescription)
            }
            
        }
    }
    
    func addMessages()  {
        if let user = currentUser {
            self.ref.child("messages").child(user.uid)
                .childByAutoId()
//                .child("message from \(String(describing: user.displayName))")
                .setValue([
                "user": user.displayName ?? "Fuga",
                "text": "Fugaaaa!",
                "timestamp": 1435285206
                ])
        }
    }
    
    func updatedUserName(username: String) {
        if let user = currentUser {
            self.ref.child("users/\(user.uid)/username").setValue(username)
        }
    }
    
    func updatedUserRoom() {
        if let user = currentUser {
            self.ref.child("users/\(user.uid)/rooms").setValue([
                user.uid: true
            ])
        }
    }
}
