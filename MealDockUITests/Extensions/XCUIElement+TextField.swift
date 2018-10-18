//
//  XCTestCase+TextField.swift
//  MealDockUITests
//
//  Created by Wataru Suzuki on 2018/11/08.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import XCTest

extension XCUIElement {
    func inputText(text: String) {
        self.tap()
        self.typeText(text)
    }
}
