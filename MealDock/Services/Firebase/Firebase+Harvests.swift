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
    
    func loadMarketItems(success:(([MarketItems]) -> Void)?, failure failureBlock : ((Error) -> ())?) {
        if let user = currentUser {
            ref.child("market_items")
                //.child("nzPmjoNg0XXGcNVRLNx6w2L3BZW2")
                .child(user.uid)//ここを指定しないとパーミッションによってはエラーになる
                .observeSingleEvent(of: .value, with: { (snapshot) in
                    var items = [MarketItems]()
                    let harvests = self.snapshotToArray(snapshot: snapshot)
                    for (index, harvest) in harvests.enumerated() {
                        if let section = Harvest.Section(rawValue: index) {
                            let item = MarketItems(type: section.toString(), harvest: harvest)
                            items.append(item)
                        } else {
                            print("Unknown section at harvest...")
                        }
                    }
                    success?(items)
                }) { (error) in
                    print(error.localizedDescription)
                    failureBlock?(error)
            }

        }
    }
    
    fileprivate func snapshotToArray(snapshot: DataSnapshot) -> [[Harvest]] {
        var items = FirebaseService.initHarvestArray()
        for child in snapshot.children {
            if let data = child as? DataSnapshot {
                if let childValue = data.value! as? [String: Any] {
                    do {
                        //let jsonData = try JSONSerialization.data(withJSONObject: childValue, options: [])
                        //let harvest = try JSONDecoder().decode(Harvest.self, from: jsonData)
                        let harvest = try FirebaseDecoder().decode(Harvest.self, from: childValue)
                        debugPrint(harvest)
                        items[harvest.getRawValue(fromDescribing: harvest.section)].append(harvest)
                    } catch let error {
                        //debugPrint(childValue)
                        print(error)
                    }
                }
            }
        }
        for i in 0..<self.harvests.count {
            items[i].sort(by: {$0.section < $1.section})
        }
        
        return items
    }
    
    func observeHarvest(success:(([[Harvest]]) -> Void)?) {
        if let user = currentUser {
            ref.child("harvests")
                //.child("nzPmjoNg0XXGcNVRLNx6w2L3BZW2")
                .child(user.uid)//ここを指定しないとパーミッションによってはエラーになる
                .observe(.value, with: { (snapshot) in
                    success?(self.snapshotToArray(snapshot: snapshot))
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
                        let marketItems = try JSONDecoder().decode([MarketItems].self, from: jsonData)
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
    
    func addHarvestToErrand(harvest: Harvest) {
        addHarvest(itemId: "harvests", harvest: harvest)
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
