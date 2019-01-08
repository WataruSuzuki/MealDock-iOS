//
//  ShowQrUITests.swift
//  MealDockUITests
//
//  Created by Wataru Suzuki on 2018/07/30.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import XCTest

class ShowQrUITests: XCTestCase {
    private let tester = ShowQrUITests.self

    override func setUp() {
        super.setUp()
        setupAsGroupMember(app: XCUIApplication())
    }
    
    override func tearDown() {
        tearDownWithGroupMember()
        super.tearDown()
    }
    
    func testShowQrAsMember() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()
        app.tabBars.buttons["Settings"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["groupInfo".localized(for: tester)].tap()
        tablesQuery.staticTexts["requestToJoin".localized(for: tester)].tap()
        let QR = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        XCTAssertNotNil(QR)
        
        app.navigationBars["MealDock.ShowQrView"].buttons["Stop"].tap()
    }
    
    
}
