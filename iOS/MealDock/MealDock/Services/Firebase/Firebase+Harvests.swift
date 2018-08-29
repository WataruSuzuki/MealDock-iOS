//
//  Firebase+Harvests.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/17.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import CodableFirebase

extension FirebaseService {
    
    func observeHarvest(success:(([Harvest]) -> Void)?) {
        if let user = currentUser {
            self.ref.child("harvests")
                //.child("nzPmjoNg0XXGcNVRLNx6w2L3BZW2")
                .child(user.uid)//ここを指定しないとパーミッションによってはエラーになる
                .observe(.value, with: { (snapshot) in
                    for child in snapshot.children {
                        if let data = child as? DataSnapshot {
                            if let childValue = data.value! as? [String: Any] {
                                do {
                                    //let jsonData = try JSONSerialization.data(withJSONObject: childValue, options: [])
                                    //let harvest = try JSONDecoder().decode(Harvest.self, from: jsonData)
                                    let harvest = try FirebaseDecoder().decode(Harvest.self, from: childValue)
                                    debugPrint(harvest)
                                    self.harvests.append(harvest)
                                } catch let error {
                                    //debugPrint(childValue)
                                    print(error)
                                }
                            }
                        }
                    }
                    self.harvests.sort(by: {$0.type < $1.type})
                    success?(self.harvests)
                }, withCancel: { (error) in
                    print(error.localizedDescription)
                })
        }
    }
    
    func addHarvests()  {
        if let user = currentUser {
            let timeStamp = String(NSDate().timeIntervalSince1970)
            let imageUrl = "https://raw.githubusercontent.com/fmn/alfred-engineer-homeru-neko-workflow/master/images/08.png"
            self.ref.child("harvests").child(user.uid)
                .childByAutoId()
                .setValue([
                    "type": "HogeFuga",
                    "image_url": imageUrl,
                    "time_stamp": timeStamp
                    ])
        }
    }
}
