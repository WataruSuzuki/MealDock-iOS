//
//  String+Localization.swift
//  MealDockUITests
//
//  Created by Wataru Suzuki on 2019/01/15.
//  Copyright © 2019 WataruSuzuki. All rights reserved.
//

import Foundation

extension String {
    
    func localized(for testCase: AnyClass) -> String {
        if let languageBundlePath = Bundle(for: testCase).path(forResource: NSLocale.current.languageCode!, ofType: "lproj") {
            if let localizationBundle = Bundle(path: languageBundlePath) {
                return NSLocalizedString(self, bundle:localizationBundle, comment: self)
            }
        }
        return NSLocalizedString(self, bundle:Bundle(for: testCase), comment: "")
    }
}
