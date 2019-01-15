//
//  DishListSceneUITest.swift
//  MealDockUITests
//
//  Created by Wataru Suzuki on 2019/01/21.
//  Copyright © 2019 WataruSuzuki. All rights reserved.
//

import XCTest

class DishListSceneUITest: XCTestCase {
    private let tester = DishListSceneUITest.self

    override func setUp() {
        super.setUp()
        setupAsGroupMember(app: XCUIApplication())
    }
    
    override func tearDown() {
        //tearDownWithGroupMember()
        super.tearDown()
    }

    func testDisplayDetail() {
        let app = XCUIApplication()
        app.tabBars.buttons["dishes".localized(for: tester)].tap()

        let uiTestMarketItemElement = app.collectionViews.cells.otherElements.containing(.staticText, identifier:"UI Test Market Item").element
        uiTestMarketItemElement.tap()
        
        let dishesButton = app.navigationBars["UI Test Market Item"].buttons["Dishes"]
        dishesButton.tap()
    }

    func testRemoveDish() {
        let app = XCUIApplication()
        app.tabBars.buttons["dishes".localized(for: tester)].tap()
        
        app.navigationBars["dishes".localized(for: tester)].buttons["select".localized(for: tester)].tap()
        
        let uiTestMarketItemElement = app.collectionViews.cells.otherElements.containing(.staticText, identifier:"UI Test Market Item").element
        uiTestMarketItemElement.tap()
        
        app.buttons["baseline local dining black 36"].tap()
    }
}
