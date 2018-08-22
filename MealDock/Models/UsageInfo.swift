//
//  UserInfo.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/08.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation

struct UsageInfo: Codable {
    let currentDock: String
    var currentID: String?
    let purchasePlan: Int
    
    enum PurchasePlan: Int {
        case free = 0,
        unlockAd,
        subscription,
        max
    }
    
    enum LimitSize: Int {
        case free = 20,
        unlockAd = 50,
        subscription = 100,
        max
    }
}

extension UsageInfo {
    init(_ currentDock: String, currentID: String?, purchasePlan: Int) {
        self.currentDock = currentDock
        self.currentID = currentID
        self.purchasePlan = purchasePlan
    }
}
