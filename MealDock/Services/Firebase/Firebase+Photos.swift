//
//  Firebase+Photos.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/18.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation

extension FirebaseService {
    
    func observePhotosToken(token:((String)->Void)?) {
        let itemId = FirebaseService.ID_PHOTOS
        if let user = currentUser {
            guard observers[itemId] == nil else {
                // Don't duplicate
                return
            }
            let newReference = rootRef.child("\(itemId)/\(user.dockID)")
            let newObserver = newReference.observe(.value, with: { (snapshot) in
                debugPrint(snapshot)
                if let value = snapshot.value as? String {
                    
                }
                token?("")
            }, withCancel: { (error) in
                print(error.localizedDescription)
            })
            observers.updateValue(FirebaseObserver(ref: newReference, handle: newObserver), forKey: itemId)
        }
    }
    
    func updatePhotosApiToken(token: String) {
        if let user = currentUser {
            let photoRef = rootRef.child(FirebaseService.ID_PHOTOS).child(user.core.uid)
            photoRef.setValue(token)
        }
    }
}
