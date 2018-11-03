//
//  Dish.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/10/06.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation

struct Dish: Codable {
    let title: String
    let description: String
    let harvests: [Harvest]
    let timeStamp: Double
    let imagePath: String
}

extension Dish {
    init(title: String, description: String, imagePath: String, harvest items: [Harvest]) {
        self.title = title
        self.description = description
        self.imagePath = imagePath
        self.harvests = items
        timeStamp = NSDate().timeIntervalSince1970
    }
}
