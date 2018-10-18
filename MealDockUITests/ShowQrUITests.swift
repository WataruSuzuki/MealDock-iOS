//
//  ShowQrUITests.swift
//  MealDockUITests
//
//  Created by Wataru Suzuki on 2018/07/30.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import XCTest

class ShowQrUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupAsGroupMember(app: XCUIApplication())
    }
    
    override func tearDown() {
        tearDownWithGroupMember()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testShowQrAsMember() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()
        app.tabBars.buttons["Settings"].tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Group Information"]/*[[".cells.staticTexts[\"Group Information\"]",".staticTexts[\"Group Information\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Request to join"]/*[[".cells.staticTexts[\"Request to join\"]",".staticTexts[\"Request to join\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let QR = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        XCTAssertNotNil(QR)
        
        app.navigationBars["MealDock.ShowQrView"].buttons["Stop"].tap()
    }
    
    
}
