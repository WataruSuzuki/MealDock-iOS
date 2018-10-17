//
//  UserInfo.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/10/08.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation

struct UsageInfo: Codable {
    let currentDock: String
    var currentID: String?
    let purchasePlan: Int
    var expireDate: Double?
    var unlockedAd: Bool?
    var unlockPremium: Bool?

    enum PurchasePlan: Int {
        case free = 0,
        unlockAd,
        unlockPremium,
        subscriptionBasic,
        max
        
        func limitSize() -> Int {
            #if SIMULATING_PURCHASED
            return 100
            #else
            switch self {
            case .unlockAd: return 40
            case .unlockPremium: return 100
            case .subscriptionBasic: return 100
            case .free: return 20
            case .max: return 20
            }
            #endif
        }
        
        func productId() -> String {
            return Bundle.main.bundleIdentifier! + "." + self.description()
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
