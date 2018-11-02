//
//  XCTestCase+Localization.swift
//  MealDockUITests
//
//  Created by Wataru Suzuki on 2018/12/01.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import XCTest

extension XCTestCase {
    class func getTestStr(key: String, sender: AnyClass, bundleClass: AnyClass) -> String {
        if let languageBundlePath = Bundle(for: sender).path(forResource: NSLocale.current.languageCode!, ofType: "lproj") {
            if let localizationBundle = Bundle(path: languageBundlePath) {
                return NSLocalizedString(key, bundle:localizationBundle, comment: "")
            }
        }
        return NSLocalizedString(key, bundle:Bundle(for: bundleClass), comment: "")
    }
    
    class func isJapanese(sender: AnyClass, bundleClass: AnyClass) -> Bool {
        return getTestStr(key: "cancel", sender: sender, bundleClass: bundleClass) == "キャンセル"
    }
}
