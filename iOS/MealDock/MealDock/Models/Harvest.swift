//
//  Harvest.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/09/18.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit

struct Harvest: Codable {
    let name: String
    let section: Int
    let imageUrl: String
    let timeStamp: String

    enum Section: Int {
        case unknown = 0,
        meat,
        fish,
        max
    }
}
