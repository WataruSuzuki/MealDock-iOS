//
//  Firebase+Reachability.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/09/25.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation

extension FirebaseService {
    func observeReachability() {
        rootRef.keepSynced(true)
        
        connectedRef = database.reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                print("Connected")
            } else {
                print("Not connected")
            }
        })
    }
    
    func exampleOnDisconnected() {
        presenceRef = Database.database().reference(withPath: "disconnectmessage");
        // Write a string when this client loses connection
        presenceRef.onDisconnectSetValue("I disconnected!")
        
        presenceRef.onDisconnectRemoveValue { error, reference in
            if let error = error {
                print("Could not establish onDisconnect event: \(error)")
            }
        }
        
        // some time later when we change our minds
        //presenceRef.cancelDisconnectOperations()
    }
}
