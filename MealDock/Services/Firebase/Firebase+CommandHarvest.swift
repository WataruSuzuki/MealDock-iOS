//
//  Firebase+Harvests.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/17.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialSnackbar

extension FirebaseService {
    
    func addToMarketItem(harvests: [Harvest]) -> Bool {
        return addHarvest(itemId: FirebaseService.ID_MARKET_ITEMS, harvests: harvests)
    }
    
    func addToErrand(harvests: [Harvest]) -> Bool {
        return addHarvest(itemId: FirebaseService.ID_CARTED_ITEMS, harvests: harvests)
    }
    
    func addToFridge(harvests: [Harvest]) {
        if addHarvest(itemId: FirebaseService.ID_FRIDGE_ITEMS, harvests: harvests) {
            removeHarvest(itemId: FirebaseService.ID_CARTED_ITEMS, harvests: harvests)
            snackBarMessage(text: "(=・∀・=)b" + NSLocalizedString("msg_mission_completed", comment: ""))
        } else {
            OptionalError.alertErrorMessage(message: NSLocalizedString("failed_of_limit_capacity", comment: ""), actions: nil)
        }
    }
    
    fileprivate func addHarvest(itemId: String, harvests: [Harvest]) -> Bool {
        guard let user = currentUser, user.hasCapacity(addingSize: harvests.count) else { return false }
        for harvest in harvests {
            let harvestRef = rootRef.child(itemId).child(user.dockID).child(harvest.name)
            setHarvestValue(ref: harvestRef, harvest: harvest)
        }
        return true
    }
    
    fileprivate func setHarvestValue(ref: DatabaseReference, harvest: Harvest) {
        ref.setValue([
            "name": harvest.name,
            "section": harvest.section,
            "imageUrl": harvest.imageUrl,
            "timeStamp": harvest.timeStamp
            ])
    }
    
    fileprivate func removeHarvest(itemId: String, harvests: [Harvest]) {
        if let user = currentUser {
            for harvest in harvests {
                rootRef.child(itemId).child(user.dockID).child(harvest.name).removeValue()
            }
        }
    }
    
    fileprivate func removeAllHarvests(itemId: String) {
        if let user = currentUser {
            rootRef.child(itemId).child(user.dockID).removeValue()
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
        if addDish(itemId: FirebaseService.ID_DISH_ITEMS, dish: dish) {
            removeHarvest(itemId: FirebaseService.ID_FRIDGE_ITEMS, harvests: dish.harvests)
        }
    }
    
    fileprivate func addDish(itemId: String, dish: Dish) -> Bool {
        guard let user = currentUser, user.hasCapacity(addingSize: 1) else { return false }
        let dishRef = rootRef.child(itemId).child(user.dockID).child(dish.title)
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
        return true
    }
    
    func removeAllMyDishes() {
        if let user = currentUser {
            rootRef.child(FirebaseService.ID_DISH_ITEMS).child(user.dockID).removeValue()
        }
    }
    
    fileprivate func removeDish(dish: Dish) {
        if let user = currentUser {
            rootRef.child(FirebaseService.ID_DISH_ITEMS)
                .child(user.dockID)
                .child(dish.title)
                .removeValue()
        }
    }
    
    func snackBarMessage(text: String) {
        let message = MDCSnackbarMessage()
        message.text = text
        MDCSnackbarManager.show(message)
    }
}
