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
    let subscriptionPlan: Int
    let sizeOfItems: Int
}

extension UsageInfo {
    init(_ currentDock: String, currentID: String?, subscriptionPlan: Int, sizeOfItems: Int) {
        self.currentDock = currentDock
        self.currentID = currentID
        self.subscriptionPlan = subscriptionPlan
        self.sizeOfItems = sizeOfItems
    }
}
