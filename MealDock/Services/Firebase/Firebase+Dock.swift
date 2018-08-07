//
//  Firebase+Dock.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/15.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation

extension FirebaseService {
    
    func observeMyDockMember(success:(([DockMember]) -> Void)?) {
        if let user = currentUser {
            ref.child("\(FirebaseService.ID_MEAL_DOCKS)/\(user.uid)")
                .observe(.value) { (snapshot) in
                    if let json = snapshot.value as? [String : String] {
                        let memberIds = [String](json.keys)
                        let memberNames = [String](json.values)
                        var members = [DockMember]()
                        for (index, id) in memberIds.enumerated() {
                            members.append(DockMember(id: id, name: memberNames[index]))
                        }
                        success?(members)
                    }
            }
        }
    }
    
    func deleteDockMember(memberId: String) {
        if let user = currentUser {
            ref.child("\(FirebaseService.ID_MEAL_DOCKS)/\(user.uid)/\(memberId)").removeValue()
        }
    }
}
