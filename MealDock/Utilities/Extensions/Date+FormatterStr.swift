//
//  Date+FormatterStr.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/11/15.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation

extension Date {
    
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
}
