//
//  Harvest.swift
//  MealDock
//
//  Created by Wataru Suzuki 2018/09/18.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit

struct Harvest: Codable {
    let name: String
    let section: String
    let imageUrl: String
    let timeStamp: Double
    var count: Int

    enum Section: Int {
        case unknown = 0,
        carbohydrate,
        dairy_soy,
        fish,
        fruit,
        meat,
        processed,
        seasoning,
        vegetable,
        max
        
        func toString() -> String {
            return String(describing: self)
        }
        
        func emoji() -> String {
            switch self {
            case .carbohydrate: return "🍚🍞🍙🥖🍜🍝"
            case .dairy_soy: return "🥛🧀🥚🍳"
            case .fish: return "🐟🐠🐡"
            case .meat: return "🍖🥩🍗🥓"
            case .vegetable:    return "🍅🍆🌽🥒🥕🥔🥦🥬"
            case .fruit:        return "🍓🍊🍎🍒🍇🍌🥝🍍"
            case .seasoning: return "🧂🍯🌶🍶"
            case .processed: return "🍯🍰🍦🍨🍔🍟🍤"
            default: return "👻"
            }
        }
    }

    static func getRawValue(fromDescribing described: String) -> Int {
        for i in 0..<Section.max.rawValue {
            if described == Section(rawValue: i)?.toString() {
                return i
            }
        }
        return 0
    }
}

extension Harvest {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
    
    init(name: String, section: String, imageUrl: String) {
        self.name = name
        self.section = section
        self.imageUrl = imageUrl
        self.count = 1
        self.timeStamp = NSDate().timeIntervalSince1970
    }
}
