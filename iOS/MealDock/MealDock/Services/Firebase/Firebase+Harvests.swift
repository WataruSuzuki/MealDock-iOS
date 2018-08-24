//
//  Firebase+Harvests.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/17.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit

extension FirebaseService {
    
    func observeHarvest(success:((DataSnapshot) -> Void)?) {
        if let user = currentUser {
            self.ref.child("harvests")
                //.child("nzPmjoNg0XXGcNVRLNx6w2L3BZW2")
                .child(user.uid)//ここを指定しないとパーミッションによってはエラーになる
                .observe(.value, with: { (snapshot) in
                    debugPrint(snapshot)
//                    if let value = snapshot.value {
//                        let data = NSKeyedArchiver.archivedData(withRootObject: value)
//                        self.allHarvests = try! JSONDecoder().decode(Array<Harvest>.self, from: data)
//                        //self.allHarvests.sort(by: {$0.type < $1.type})
//                        self.targetHarvests = self.allHarvests
//                    }
                    success?(snapshot)
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
