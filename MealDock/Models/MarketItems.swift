//
//  DefalutErrands.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/09/27.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation

struct MarketItems: Codable {
    let type: String
    let items: [Harvest]
}

extension MarketItems {
    init(type: String, harvest items: [Harvest]) {
        self.type = type
        self.items = items
    }
}
