//
//  UserInfo.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/08.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation

struct UsageInfo: Codable {
    let currentDock: [[String: String]]
    let subscriptionPlan: Int
    let sizeOfItems: Int
}

extension UsageInfo {
    init(_ currentDock: [[String: String]], subscriptionPlan: Int, sizeOfItems: Int) {
        self.currentDock = currentDock
        self.subscriptionPlan = subscriptionPlan
        self.sizeOfItems = sizeOfItems
    }
}
