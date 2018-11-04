//
//  Firebase+Harvests.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/09/17.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Firebase
import MaterialComponents.MaterialSnackbar

extension FirebaseService {
    
    func addCustomMarketItem(harvests: [Harvest]) -> Bool {
        return addHarvest(itemId: FirebaseService.ID_MARKET_ITEMS, harvests: harvests)
    }
    
    func removeMarketItem(harvest: Harvest) {
        decrementHarvest(itemId: FirebaseService.ID_MARKET_ITEMS, harvests: [harvest])
    }
    
    func addToErrand(harvests: [Harvest]) -> Bool {
        return addHarvest(itemId: FirebaseService.ID_CARTED_ITEMS, harvests: harvests)
    }
    
    func addToFridge(harvests: [Harvest]) {
        if addHarvest(itemId: FirebaseService.ID_FRIDGE_ITEMS, harvests: harvests, isInFridge: true) {
            decrementHarvest(itemId: FirebaseService.ID_CARTED_ITEMS, harvests: harvests)
            UIViewController.snackBarMessage(text: "(=・∀・=)b \n" + NSLocalizedString("msg_mission_completed", comment: ""))
        } else {
            OptionalError.alertErrorMessage(message: NSLocalizedString("failed_of_limit_capacity", comment: ""), actions: nil)
        }
    }
    
    private func addHarvest(itemId: String, harvests: [Harvest]) -> Bool {
        return addHarvest(itemId: itemId, harvests: harvests, isInFridge: false)
    }
    
    private func addHarvest(itemId: String, harvests: [Harvest], isInFridge: Bool) -> Bool {
        guard let user = currentUser else { return false }
        guard isInFridge || user.hasCapacity(addingSize: harvests.count) else { return false }
        for harvest in harvests {
            setHarvestValue(itemId: itemId, user: user, harvest: harvest)
        }
        return true
    }
    
    fileprivate func setHarvestValue(itemId: String, user: DockUser, harvest: Harvest) {
        let harvestRef = rootRef.child(itemId).child(user.dockID).child(harvest.name)
        loadHarvestCount(itemId: itemId, harvestName: harvest.name) { (current) in
            harvestRef.child("count").setValue(harvest.count + current)
        }
        harvestRef.child("name").setValue(harvest.name)
        harvestRef.child("section").setValue(harvest.section)
        harvestRef.child("imageUrl").setValue(harvest.imageUrl)
        harvestRef.child("timeStamp").setValue(harvest.timeStamp)
    }
    
    fileprivate func decrementHarvest(itemId: String, harvests: [Harvest]) {
        if let user = currentUser {
            for harvest in harvests {
                let ref = rootRef.child(itemId).child(user.dockID).child(harvest.name)
                loadHarvestCount(itemId: itemId, harvestName: harvest.name) { (current) in
                    let next = current - harvest.count
                    if next > 0 {
                        ref.child("count").setValue(next)
                    } else {
                        ref.removeValue()
                    }
                }
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
            decrementHarvest(itemId: FirebaseService.ID_FRIDGE_ITEMS, harvests: dish.harvests)
        }
    }
    
    fileprivate func addDish(itemId: String, dish: Dish) -> Bool {
        guard let user = currentUser else { return false }
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
    
    func removeDishes(dishes: [Dish]) {
        if let user = currentUser {
            for dish in dishes {
                rootRef.child(FirebaseService.ID_DISH_ITEMS)
                    .child(user.dockID).child(dish.title).removeValue()
            }
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
}
