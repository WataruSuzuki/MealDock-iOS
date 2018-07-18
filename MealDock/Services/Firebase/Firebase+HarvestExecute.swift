//
//  Firebase+Harvests.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/17.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import Alamofire

extension FirebaseService {
    
    func registerDefaultMarketItems() {
        let jsonUrl = "https://watarusuzuki.github.io/MealDock/default_market_items.json"
        Alamofire.request(jsonUrl).responseJSON { (response) in
            if response.result.isSuccess {
                if let jsonData = response.data {
                    do {
                        let marketItems = try JSONDecoder().decode([MarketItems].self, from: jsonData)
                        for type in marketItems {
                            for harvest in type.items {
                                debugPrint(harvest)
                                self.addToMarketItem(harvest: harvest)
                            }
                        }
                        
                    } catch let error {
                        print(error)
                    }
                }
            }
        }
    }
    
    func addToMarketItem(harvest: Harvest) {
        addHarvest(itemId: FirebaseService.ID_MARKET_ITEMS, harvest: harvest)
    }
    
    func addToErrand(harvest: Harvest) {
        addHarvest(itemId: FirebaseService.ID_CARTED_ITEMS, harvest: harvest)
    }
    
    func addToFridge(harvest: Harvest) {
        addHarvest(itemId: FirebaseService.ID_FRIDGE_ITEMS, harvest: harvest)
        removeHarvest(itemId: FirebaseService.ID_CARTED_ITEMS, harvest: harvest)
    }
    
    fileprivate func addHarvest(itemId: String, harvest: Harvest) {
        if let user = currentUser {
            let harvestRef = ref.child(itemId).child(user.uid).child(harvest.name)
            setHarvestValue(ref: harvestRef, harvest: harvest)
        }
    }
    
    fileprivate func setHarvestValue(ref: DatabaseReference, harvest: Harvest) {
        ref.setValue([
            "name": harvest.name,
            "section": harvest.section,
            "imageUrl": harvest.imageUrl,
            "timeStamp": harvest.timeStamp
            ])
    }
    
    fileprivate func removeHarvest(itemId: String, harvest: Harvest) {
        if let user = currentUser {
            ref.child(itemId).child(user.uid).child(harvest.name).removeValue()
        }
    }
    
    fileprivate func removeAllHarvests(itemId: String) {
        if let user = currentUser {
            ref.child(itemId).child(user.uid).removeValue()
        }
    }
    
    func removeAllMarketItems() {
        removeAllHarvests(itemId: FirebaseService.ID_MARKET_ITEMS)
    }
    
    func removeAllCartedHarvest() {
        removeAllHarvests(itemId: FirebaseService.ID_CARTED_ITEMS)
    }
    
    func removeAllInFridgeHarvest() {
        removeAllHarvests(itemId: FirebaseService.ID_DISH_ITEMS)
    }
    
    func addDish(dish: Dish) {
        addDish(itemId: FirebaseService.ID_DISH_ITEMS, dish: dish)
        for harvest in dish.harvests {
            removeHarvest(itemId: FirebaseService.ID_FRIDGE_ITEMS, harvest: harvest)
        }
    }
    
    fileprivate func addDish(itemId: String, dish: Dish) {
        if let user = currentUser {
            let dishRef = ref.child(itemId).child(user.uid).child(dish.title)
            var harvestArray = [Any]()
            for harvest in dish.harvests {
                harvestArray.append(try! harvest.asDictionary())
            }
            dishRef.setValue([
                "title": dish.title,
                "description": dish.description,
                "imagePath": dish.imagePath,
                "harvests": harvestArray,
                "timeStamp": dish.timeStamp
                ])
            
        }
    }
    
    func removeAllMyDishes() {
        if let user = currentUser {
            ref.child(FirebaseService.ID_DISH_ITEMS).child(user.uid).removeValue()
        }
    }
    
    fileprivate func removeDish(dish: Dish) {
        if let user = currentUser {
            ref.child(FirebaseService.ID_DISH_ITEMS).child(user.uid).child(dish.title).removeValue()
        }
    }
}
