//
//  Firebase+Observe.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/06.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation
import Alamofire
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
        var mergedItems = [MarketItems]()
        loadDefaultMarketItems { (defaultItems, error) in
            if let error = error {
                failureBlock?(error)
            } else {
                self.loadCustomMarketItems(result: { (customItems, error) in
                    if let error = error {
                        debugPrint(error)
                        mergedItems = defaultItems
                    } else {
                        mergedItems.append(MarketItems(type: Harvest.Section.unknown.toString(), harvest: customItems[Harvest.Section.unknown.rawValue].items))
                        for customItem in customItems {
                            for defaultItem in defaultItems {
                                if customItem.type == defaultItem.type {
                                    mergedItems.append(MarketItems(type: customItem.type, harvest: customItem.items + defaultItem.items))
                                }
                            }
                        }
                    }
                    mergedItems.sort(by: {Harvest.getRawValue(fromDescribing: $0.type) < Harvest.getRawValue(fromDescribing: $1.type)})
                    success?(mergedItems)
                })
            }
        }
    }
    
    fileprivate func loadCustomMarketItems(result:(([MarketItems], Error?) -> Void)?) {
        if let user = currentUser {
            rootRef.child(FirebaseService.ID_MARKET_ITEMS)
                .child(user.dockID)
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
                    result?(items, nil)
                }) { (error) in
                    print(error.localizedDescription)
                    result?([MarketItems](), error)
            }
        }
    }
    
    fileprivate func loadDefaultMarketItems(result:(([MarketItems], Error?) -> Void)?) {
        let jsonUrl = "https://watarusuzuki.github.io/MealDock/default_market_items.json"
        Alamofire.request(jsonUrl).responseJSON { (response) in
            guard response.result.isSuccess, let jsonData = response.data else {
                    result?([MarketItems](), response.result.error!)
                    return
            }
            do {
                let marketItems = try JSONDecoder().decode([MarketItems].self, from: jsonData)
                result?(marketItems, nil)
            } catch let error {
                print(error)
                result?([MarketItems](), error)
            }
        }
    }
    
    fileprivate func observeHarvest(itemId: String, success:(([[Harvest]]) -> Void)?) {
        if let user = currentUser {
            guard observers[itemId] == nil else {
                // Don't duplicate
                return
            }
            let newReference = rootRef.child("\(itemId)/\(user.dockID)")
            let newObserver = newReference.observe(.value, with: { (snapshot) in
                let items = self.snapshotToHarvests(snapshot: snapshot)
                self.itemCounters.updateValue(items.count, forKey: itemId)
                success?(items)
            }, withCancel: { (error) in
                print(error.localizedDescription)
            })
            observers.updateValue(FirebaseObserver(ref: newReference, handle: newObserver), forKey: itemId)
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
                        items[Harvest.getRawValue(fromDescribing: harvest.section)].append(harvest)
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
        if let _ = usageInfoKVO {
            observeDishes(user: currentUser!, success: success)
        } else {
            let kvo = observe(\.usageInfoKVO) { (value, change) in
                self.signInObservations["observeDishes"]?.invalidate()
                self.observeDishes(user: self.currentUser!, success: success)
            }
            signInObservations.updateValue(kvo, forKey: "observeDishes")
        }
    }
    
    fileprivate func observeDishes(user: DockUser, success:(([Dish]) -> Void)?) {
        let itemId = FirebaseService.ID_DISH_ITEMS
        guard observers[itemId] == nil else {
            // Don't duplicate
            return
        }
        let newReference = rootRef.child("\(itemId)/\(user.dockID)")
        let newObserver = newReference.observe(.value, with: { (snapshot) in
            var items = [Dish]()
            for child in snapshot.children {
                debugPrint(child)
                if let data = child as? DataSnapshot {
                    if let childValue = data.value! as? [String: Any] {
                        do {
                            let dish = try FirebaseDecoder().decode(Dish.self, from: childValue)
                            items.append(dish)
                        } catch let error {
                            print(error)
                        }
                    }
                }
            }
            self.itemCounters.updateValue(items.count, forKey: itemId)
            items.sort(by: {$0.timeStamp < $1.timeStamp})
            if !PurchaseService.shared.isPurchased {
                let fakeDish = Dish(title: "💩", description: "Ad", imagePath: "", harvest: [])
                let count = items.count
                for index in 0..<count {
                    if index % 5 == 0 {
                        items.insert(fakeDish, at: index)
                    }
                }
            }
            success?(items)
        }, withCancel: { (error) in
            print(error.localizedDescription)
        })
        observers.updateValue(FirebaseObserver(ref: newReference, handle: newObserver), forKey: itemId)
    }
}
