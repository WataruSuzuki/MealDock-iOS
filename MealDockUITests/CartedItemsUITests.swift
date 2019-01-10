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

    func testPopMenuSelectShare() {
        let app = XCUIApplication()
        app.tabBars.buttons["Carted Foods"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.cells.containing(.staticText, identifier:"UI Test Market Item").buttons["Increment"].tap()
        tablesQuery.buttons["freezer"].press(forDuration: 2.0);
        
        XCUIApplication().staticTexts["Share"].tap()
        waitingSec(sec: 2.0, sender: self)
        
        app/*@START_MENU_TOKEN@*/.otherElements["PopoverDismissRegion"]/*[[".otherElements[\"dismiss popup\"]",".otherElements[\"PopoverDismissRegion\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    }

}
