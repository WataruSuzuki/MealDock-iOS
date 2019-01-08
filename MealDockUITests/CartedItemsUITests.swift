//
//  CartedItemsUITests.swift
//  MealDockUITests
//
//  Created by 鈴木航 on 2019/01/18.
//  Copyright © 2019 WataruSuzuki. All rights reserved.
//

import XCTest

class CartedItemsUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        setupAsGroupMember(app: XCUIApplication())
    }
    
    override func tearDown() {
        tearDownWithGroupMember()
        super.tearDown()
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.tabBars.buttons["Carted Foods"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.cells.containing(.staticText, identifier:"UI Test Market Item").buttons["Increment"].tap()
        tablesQuery.buttons["freezer"].press(forDuration: 2.0);
        
    }

}
