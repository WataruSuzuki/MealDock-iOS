//
//  Firebase+Observe.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/06.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation
import CodableFirebase

extension FirebaseService {
    
    func observeCartedHarvest(success:(([[Harvest]]) -> Void)?) {
        observeHarvest(itemId: FirebaseService.ID_CARTED_ITEMS) { (items) in
            success?(items)
        }
    }
    
    func observeInFridgeHarvest(success:(([[Harvest]]) -> Void)?) {
        observeHarvest(itemId: FirebaseService.ID_FRIDGE_ITEMS) { (items) in
            success?(items)
        }
    }
    
    func loadMarketItems(success:(([MarketItems]) -> Void)?, failure failureBlock : ((Error) -> ())?) {
        if let user = currentUser {
            ref.child(FirebaseService.ID_MARKET_ITEMS)
                //.child("nzPmjoNg0XXGcNVRLNx6w2L3BZW2")
                .child(user.uid)//ここを指定しないとパーミッションによってはエラーになる
                .observeSingleEvent(of: .value, with: { (snapshot) in
                    var items = [MarketItems]()
                    let harvests = self.snapshotToHarvests(snapshot: snapshot)
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
    
    fileprivate func observeHarvest(itemId: String, success:(([[Harvest]]) -> Void)?) {
        if let user = currentUser {
            ref.child(itemId)
                //.child("nzPmjoNg0XXGcNVRLNx6w2L3BZW2")
                .child(user.uid)//ここを指定しないとパーミッションによってはエラーになる
                .observe(.value, with: { (snapshot) in
                    success?(self.snapshotToHarvests(snapshot: snapshot))
                }, withCancel: { (error) in
                    print(error.localizedDescription)
                })
        }
    }

    
    fileprivate func snapshotToHarvests(snapshot: DataSnapshot) -> [[Harvest]] {
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
        for i in 0..<items.count {
            items[i].sort(by: {$0.section < $1.section})
        }
        
        return items
    }
    
    func observeDishes(success:(([Dish]) -> Void)?) {
        if let user = currentUser {
            observeDishes(user: user, success: success)
        } else {
            let handle = observe(\.currentUser) { (user, change) in
                self.observeDishes(user: self.currentUser!, success: success)
                self.signInObservations["observeDishes"]?.invalidate()
            }
            signInObservations.updateValue(handle, forKey: "observeDishes")
        }
    }
    
    fileprivate func observeDishes(user: User, success:(([Dish]) -> Void)?) {
        ref.child(FirebaseService.ID_DISH_ITEMS)
            //.child("nzPmjoNg0XXGcNVRLNx6w2L3BZW2")
            .child(user.uid)
            .observe(.value, with: { (snapshot) in
                var items = [Dish]()
                for child in snapshot.children {
                    debugPrint(child)
                    if let data = child as? DataSnapshot {
                        if let childValue = data.value! as? [String: Any] {
                            do {
                                let dish = try FirebaseDecoder().decode(Dish.self, from: childValue)
                                items.append(dish)
                            } catch let error {
                                //debugPrint(childValue)
                                print(error)
                            }
                        }
                    }
                }
                items.sort(by: {$0.timeStamp < $1.timeStamp})
                success?(items)
            }, withCancel: { (error) in
                print(error.localizedDescription)
            })
    }
}
