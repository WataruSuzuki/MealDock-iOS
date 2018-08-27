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
    var expireDate: Double?
    var unlockedAd: Bool?
    
    enum PurchasePlan: Int {
        case free = 0,
        unlockAd,
        subscription,
        max
        
        func limitSize() -> Int {
            switch self {
            case .unlockAd: return 50
            case .subscription: return 100
            case .free: fallthrough
            default:
                return 20
            }
        }
    }
}

extension UsageInfo {
    init(_ currentDock: String, currentID: String?, purchasePlan: Int) {
        self.currentDock = currentDock
        self.currentID = currentID
        self.purchasePlan = purchasePlan
    }
}
