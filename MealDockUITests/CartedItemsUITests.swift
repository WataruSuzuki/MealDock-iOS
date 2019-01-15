//
//  CartedItemsUITests.swift
//  MealDockUITests
//
//  Created by Wataru Suzuki on 2019/01/18.
//  Copyright © 2019 WataruSuzuki. All rights reserved.
//

import XCTest

class CartedItemsUITests: XCTestCase {
    private let tester = CartedItemsUITests.self

    override func setUp() {
        super.setUp()
        setupAsGroupMember(app: XCUIApplication())
    }
    
    override func tearDown() {
        //tearDownWithGroupMember()
        super.tearDown()
    }

    func testPopMenuSelectShare() {
        let app = XCUIApplication()
        app.tabBars.buttons["cartedFoods".localized(for: tester)].tap()
        
        let tablesQuery = app.tables
        tablesQuery.cells.containing(.staticText, identifier: uiTestItemName).buttons["Increment"].tap()
        tablesQuery.buttons["freezer"].press(forDuration: 2.0);
        
        XCUIApplication().staticTexts["share".localized(for: tester)].tap()
        waitingSec(sec: 2.0, sender: self)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            app/*@START_MENU_TOKEN@*/.otherElements["PopoverDismissRegion"]/*[[".otherElements[\"dismiss popup\"]",".otherElements[\"PopoverDismissRegion\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        } else {
            app.buttons["cancel".localized(for: tester)].tap()
        }
    }

}
