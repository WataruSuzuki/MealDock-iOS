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
            rootRef.child("\(FirebaseService.ID_USAGE)/\(user.core.uid)/currentDock").setValue(dock ?? user.core.uid)
            rootRef.child("\(FirebaseService.ID_USAGE)/\(user.core.uid)/currentID").setValue(id ?? user.core.uid)
            clearAllObservers(evenUserInfo: false)
        }
    }
    
    func observeMyDockMember(success:(([DockMember]) -> Void)?) {
        if let user = currentUser {
            let itemId = FirebaseService.ID_MEAL_DOCKS
            guard observers[itemId] == nil else {
                // Don't duplicate
                return
            }
            let newReference = rootRef.child("\(itemId)/\(user.core.uid)")
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
    
    func removeMemberObsever() {
        if let observer = observers[FirebaseService.ID_MEAL_DOCKS] {
            observer.ref.removeObserver(withHandle: observer.handle)
            observers.removeValue(forKey: FirebaseService.ID_MEAL_DOCKS)
        }
    }
    
    func addMyDockGroupMember(memberId: String, name: String) {
        if let user = currentUser {
            rootRef.child("\(FirebaseService.ID_MEAL_DOCKS)/\(user.core.uid)").child(memberId).setValue(name)
        }
    }
    
    func deleteDockMember(memberId: String) {
        if let user = currentUser {
            rootRef.child("\(FirebaseService.ID_MEAL_DOCKS)/\(user.core.uid)/\(memberId)").removeValue()
        }
    }
}
