//
//  XCTestCase+Localization.swift
//  MealDockUITests
//
//  Created by Wataru Suzuki on 2018/12/01.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    class func isJapanese(sender: AnyClass) -> Bool {
        return "cancel".localized(for: sender) == "キャンセル"
    }
}
