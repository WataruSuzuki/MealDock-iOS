//
//  Firebase+Harvests.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/17.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import Alamofire
import CodableFirebase

extension FirebaseService {
    
    func observeHarvest(success:(([[Harvest]]) -> Void)?) {
        if let user = currentUser {
            ref.child("harvests")
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
                                    self.harvests[harvest.getRawValue(fromDescribing: harvest.section)].append(harvest)
                                } catch let error {
                                    //debugPrint(childValue)
                                    print(error)
                                }
                            }
                        }
                    }
                    for i in 0..<self.harvests.count {
                        self.harvests[i].sort(by: {$0.section < $1.section})
                    }
                    success?(self.harvests)
                }, withCancel: { (error) in
                    print(error.localizedDescription)
                })
        }
    }
    
    func addDefaultErrands() {
        let jsonUrl = "https://watarusuzuki.github.io/MealDock/default_market_items.json"
        Alamofire.request(jsonUrl).responseJSON { (response) in
            if response.result.isSuccess {
                if let jsonData = response.data {
                    do {
                        let marketItems = try JSONDecoder().decode([DefalutMarketItems].self, from: jsonData)
                        for type in marketItems {
                            for harvest in type.items {
                                debugPrint(harvest)
                                self.addMarketItem(harvest: harvest)
                            }
                        }
                        
                    } catch let error {
                        print(error)
                    }
                }
            }
        }
    }
    
    func addMarketItem(harvest: Harvest) {
        addHarvest(itemId: "market_items", harvest: harvest)
    }
    
    func addErrand() {
        let imageUrl = "https://raw.githubusercontent.com/fmn/alfred-engineer-homeru-neko-workflow/master/images/08.png"
        let itemId = "harvests"
    }
    
    fileprivate func addHarvest(itemId: String, harvest: Harvest) {
        if let user = currentUser {
            ref.child(itemId).child(user.uid).child(harvest.name)
                .setValue([
                    "name": harvest.name,
                    "section": harvest.section,
                    "imageUrl": harvest.imageUrl,
                    "timeStamp": harvest.timeStamp
                    ])
        }
    }
}
