//
//  Firebase+Photos.swift
//  MealDock
//
//  Created by Wataru Suzuki 2018/10/18.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation

extension FirebaseService {
    
    func observePhotosToken(token:((String)->Void)?) {
        observePhotosAccessKey(childItem: "token", completion: token)
    }
    
    func observePhotosAlbumId(id:((String)->Void)?) {
        observePhotosAccessKey(childItem: "albumId", completion: id)
    }
    
    private func observePhotosAccessKey(childItem: String, completion:((String)->Void)?) {
        let itemId = FirebaseService.ID_PHOTOS
        if let user = currentUser {
            guard observers[itemId] == nil else {
                // Don't duplicate
                return
            }
            let newReference = rootRef.child("\(itemId)/\(user.dockID)/\(childItem)")
            let newObserver = newReference.observe(.value, with: { (snapshot) in
                debugPrint(snapshot)
                guard let value = snapshot.value as? String else {
                    completion?("")
                    return
                }
                completion?(value)
            }, withCancel: { (error) in
                print(error.localizedDescription)
            })
            observers.updateValue(FirebaseObserver(ref: newReference, handle: newObserver), forKey: itemId)
        }
    }
    
    func updatePhotosApiToken(token: String) {
        if let user = currentUser {
            rootRef.child("\(FirebaseService.ID_PHOTOS)/\(user.core.uid)/token").setValue(token)
        }
    }
    
    func updatePhotosAlbumId(id: String) {
        if let user = currentUser {
            rootRef.child("\(FirebaseService.ID_PHOTOS)/\(user.core.uid)/albumId").setValue(id)
        }
    }
}
