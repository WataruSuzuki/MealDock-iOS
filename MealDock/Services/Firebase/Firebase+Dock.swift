//
//  Firebase+Dock.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/15.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation

extension FirebaseService {
    
    func joinToGroupDock(dock: String?, id: String?) {
        if let user = currentUser {
            rootRef.child("\(FirebaseService.ID_USAGE)/\(user.uid)/currentDock").setValue(dock ?? user.uid)
            rootRef.child("\(FirebaseService.ID_USAGE)/\(user.uid)/currentID").setValue(id ?? user.uid)
            clearAllObservers()
        }
    }
    
    func observeMyDockMember(success:(([DockMember]) -> Void)?) {
        if let user = currentUser {
            let itemId = FirebaseService.ID_MEAL_DOCKS
            guard observers[itemId] == nil else {
                // Don't duplicate
                return
            }
            let newReference = rootRef.child("\(itemId)/\(user.uid)")
            let newObserver = newReference.observe(.value) { (snapshot) in
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
            observers.updateValue(FirebaseObserver(ref: newReference, handle: newObserver), forKey: itemId)
        }
    }
    
    func addMyDockGroupMember(memberId: String, name: String) {
        if let user = currentUser {
            rootRef.child("\(FirebaseService.ID_MEAL_DOCKS)/\(user.uid)").child(memberId).setValue(name)
        }
    }
    
    func deleteDockMember(memberId: String) {
        if let user = currentUser {
            rootRef.child("\(FirebaseService.ID_MEAL_DOCKS)/\(user.uid)/\(memberId)").removeValue()
        }
    }
}
