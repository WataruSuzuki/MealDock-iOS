//
//  String+Localized.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2019/01/09.
//  Copyright © 2019 WataruSuzuki. All rights reserved.
//

import Foundation

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    
    var purchaseWord: String {
        return NSLocalizedString(self, tableName: "InAppPurchase", comment: "")
    }
    
    var foodName: String {
        return NSLocalizedString(self, tableName: "MarketItems", comment: "")
    }
}
