//
//  UserInfo.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/08.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation

struct UserInfo: Codable {
    let subscriptionPlan: Int
    let storage: Int
    let countOfCartedItems: Int
    let countOfInFridgeItems: Int
    let countOfErrandItems: Int
    let countOfDishes: Int
}

extension UserInfo {
    init(_ subscriptionPlan: Int, storage: Int,
         countOfCartedItem: Int, countOfInFridgeItems: Int, countOfErrandItems: Int, countOfDishes: Int) {
        self.subscriptionPlan = subscriptionPlan
        self.storage = storage
        self.countOfCartedItems = countOfCartedItem
        self.countOfInFridgeItems = countOfInFridgeItems
        self.countOfErrandItems = countOfErrandItems
        self.countOfDishes = countOfDishes
    }
}