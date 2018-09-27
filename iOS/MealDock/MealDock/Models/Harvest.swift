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
    let section: String
    let imageUrl: String
    let timeStamp: Int

    enum Section: Int {
        case unknown = 0,
        meat,
        fish,
        max
        
        func toString() -> String {
            return String(describing: self)
        }
    }

    func getRawValue(fromDescribing described: String) -> Int {
        for i in 0..<Section.max.rawValue {
            if described == Section(rawValue: i)?.toString() {
                return i
            }
        }
        return 0
    }
}
