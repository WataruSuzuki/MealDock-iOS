//
//  Firebase+Harvests.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/17.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit

extension FirebaseService {
    func observeHarvestSingleEvent() {
        if let user = currentUser {
            self.ref.child("harvests")
                //.child("nzPmjoNg0XXGcNVRLNx6w2L3BZW2")
                .child(user.uid)//ここを指定しないとパーミッションによってはエラーになる
                .observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot)
                }) { (error) in
                    print(error.localizedDescription)
            }
            
        }
    }
    
    func addHarvests()  {
        if let user = currentUser {
            self.ref.child("harvests").child(user.uid)
                .childByAutoId()
                .setValue([
                    "user": user.displayName ?? "Fuga",
                    "text": "Fugaaaa!",
                    "timestamp": 1435285206
                    ])
        }
    }
}
