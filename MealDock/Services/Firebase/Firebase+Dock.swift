//
//  Firebase+Dock.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/15.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation

extension FirebaseService {
    
    func observeMyDockMember() {
        if let user = currentUser {
            ref.child("\(FirebaseService.ID_MEAL_DOCKS)/\(user.uid)")
                .observe(.value) { (snapshot) in
                    debugPrint(snapshot)
            }
        }
    }
    
    func deleteDockMember(memberId: String) {
        if let user = currentUser {
            ref.child("\(FirebaseService.ID_MEAL_DOCKS)/\(user.uid)/\(memberId)").removeValue()
        }
    }
}
