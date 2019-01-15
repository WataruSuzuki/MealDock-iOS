//
//  String+Localization.swift
//  MealDockUITests
//
//  Created by Wataru Suzuki on 2019/01/15.
//  Copyright © 2019 WataruSuzuki. All rights reserved.
//

import Foundation

extension String {
    
    func foodName(for testCase: AnyClass) -> String {
        if let languageBundlePath = getTestBundlePath(for: testCase),
            let localizationBundle = Bundle(path: languageBundlePath) {
            return NSLocalizedString(self, tableName: "MarketItems", bundle: localizationBundle, comment: self)
        }
        return NSLocalizedString(self, tableName: "MarketItems", bundle: Bundle(for: testCase), comment: "")
    }
    
    func localized(for testCase: AnyClass) -> String {
        if let languageBundlePath = getTestBundlePath(for: testCase),
            let localizationBundle = Bundle(path: languageBundlePath) {
                return NSLocalizedString(self, bundle: localizationBundle, comment: self)
        }
        return NSLocalizedString(self, bundle: Bundle(for: testCase), comment: "")
    }
    
    func getTestBundlePath(for testCase: AnyClass) -> String? {
        return Bundle(for: testCase).path(forResource: NSLocale.current.languageCode!, ofType: "lproj")
    }
}
