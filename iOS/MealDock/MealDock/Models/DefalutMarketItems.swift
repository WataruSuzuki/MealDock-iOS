//
//  DefalutErrands.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/09/27.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation

struct DefalutMarketItems: Codable {
    let name: String
    let children: [Harvest]
    
    enum Section: Int {
        case unknown = 0,
        meat,
        fish,
        max
    }
}
