//
//  ErrandSceneUITests.swift
//  MealDockUITests
//
//  Created by Wataru Suzuki on 2018/11/08.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import XCTest

class ErrandSceneUITests: XCTestCase {

    static let itemName = "UI Test Market Item"
    private let tester = ErrandSceneUITests.self
    
    override func setUp() {
        super.setUp()
        setupAsGroupMember(app: XCUIApplication())
    }

    override func tearDown() {
        tearDownWithGroupMember()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAddNewMarketItem() {
        let app = XCUIApplication()
        let cartedFood = XCTestCase.getTestStr(key: "cartedFoods", sender: tester, bundleClass: tester)
        app.tabBars.buttons[cartedFood].tap()
        app.navigationBars[cartedFood].buttons["Add"].tap()
        
        let addNewMarketItem = XCTestCase.getTestStr(key: "addNewMarketItem", sender: tester, bundleClass: tester)
        app.buttons[addNewMarketItem].tap()
        
        let titleTextField = app.collectionViews.textFields[XCTestCase.getTestStr(key: "title", sender: tester, bundleClass: tester)]
        titleTextField.inputText(text: ErrandSceneUITests.itemName)
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.textFields["Title"]/*[[".cells.textFields[\"Title\"]",".textFields[\"Title\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["👻"]/*[[".cells.staticTexts[\"👻\"]",".staticTexts[\"👻\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        app.pickerWheels.element.adjust(toPickerWheelValue: "🍅🍆🌽🥒🥕🥔🥦🥬")
        app.pickerWheels["🍅🍆🌽🥒🥕🥔🥦🥬"].tap()
        
        app.toolbars["Toolbar"].buttons["Done"].tap()
        app.navigationBars[addNewMarketItem].buttons["Save"].tap()
        
        app.collectionViews.staticTexts["🍅🍆🌽🥒🥕🥔🥦🥬"].tap()
        app.scrollViews.otherElements.collectionViews.cells.containing(.staticText, identifier:ErrandSceneUITests.itemName).children(matching: .other).element.tap()
        app.navigationBars[XCTestCase.getTestStr(key: "errandFoods", sender: tester, bundleClass: tester)].buttons["Done"].tap()
    }
    
    func testDeleteCustomMarketItem() {
        let app = XCUIApplication()
        let cartedFood = XCTestCase.getTestStr(key: "cartedFoods", sender: tester, bundleClass: tester)
        app.tabBars.buttons[cartedFood].tap()
        app.navigationBars[cartedFood].buttons["Add"].tap()
        app.buttons["baseline more horiz black 36pt"].tap()
        let editCustomItem = XCTestCase.getTestStr(key: "editCustomItem", sender: tester, bundleClass: tester)
        app.sheets["menu"].buttons[editCustomItem].tap()
        
        let tablesQuery = app.tables
        tablesQuery.cells.staticTexts[ErrandSceneUITests.itemName].swipeLeft()
        tablesQuery.buttons["Delete"].tap()
        
        let deleted = tablesQuery.cells.staticTexts[ErrandSceneUITests.itemName]
        XCTAssertFalse(deleted.exists)
        
        app.navigationBars[editCustomItem].buttons["Done"].tap()
        app.buttons["baseline more horiz black 36pt"].tap()
        app.sheets["menu"].buttons[editCustomItem].tap()
        app.navigationBars[editCustomItem].buttons["Done"].tap()
        app.navigationBars[XCTestCase.getTestStr(key: "errandFoods", sender: tester, bundleClass: tester)].buttons["Cancel"].tap()
    }

}
