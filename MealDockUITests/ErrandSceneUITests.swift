//
//  ErrandSceneUITests.swift
//  MealDockUITests
//
//  Created by Wataru Suzuki on 2018/11/08.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import XCTest

class ErrandSceneUITests: XCTestCase {

    private let tester = ErrandSceneUITests.self
    
    override func setUp() {
        super.setUp()
        setupAsGroupMember(app: XCUIApplication())
    }

    override func tearDown() {
        //tearDownWithGroupMember()
        super.tearDown()
    }

    func testAddNewMarketItem() {
        let app = XCUIApplication()
        let cartedFood = "cartedFoods".localized(for: tester)
        app.tabBars.buttons[cartedFood].tap()
        app.navigationBars[cartedFood].buttons["Add"].tap()
        
        let addNewMarketItem = "addNewMarketItem".localized(for: tester)
        app.buttons[addNewMarketItem].tap()
        
        let scanBarcode = "msg_scan_barcode".localized(for: tester)
        let skip = "skip".localized(for: tester)
        app.navigationBars[scanBarcode].buttons[skip].tap()
        waitingSec(sec: 5.0, sender: self)

        let titleTextField = app.collectionViews.textFields["title".localized(for: tester)]
        titleTextField.inputText(text: uiTestItemName)
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["title".localized(for: tester)].tap()
        collectionViewsQuery.staticTexts["👻"].tap()
        
        app.pickerWheels.element.adjust(toPickerWheelValue: "🍅🍆🌽🥒🥕🥔🥦🥬")
        app.pickerWheels["🍅🍆🌽🥒🥕🥔🥦🥬"].tap()
        
        app.toolbars["Toolbar"].buttons["Done"].tap()
        app.navigationBars[addNewMarketItem].buttons["Save"].tap()
        
        app.collectionViews.staticTexts["🍅🍆🌽🥒🥕🥔🥦🥬"].tap()
        app.scrollViews.otherElements.collectionViews.cells.containing(.staticText, identifier:uiTestItemName).children(matching: .other).element.tap()
        app.navigationBars["errandFoods".localized(for: tester)].buttons["Done"].tap()
    }
    
    func testDeleteCustomMarketItem() {
        let app = XCUIApplication()
        let cartedFood = "cartedFoods".localized(for: tester)
        app.tabBars.buttons[cartedFood].tap()
        app.navigationBars[cartedFood].buttons["Add"].tap()
        app.buttons["baseline more horiz black 36pt"].tap()
        let editCustomItem = "editCustomItem".localized(for: tester)
        app.sheets["menu".localized(for: tester)].buttons[editCustomItem].tap()
        
        let tablesQuery = app.tables
        tablesQuery.cells.staticTexts[uiTestItemName].swipeLeft()
        tablesQuery.buttons["Delete"].tap()
        
        let deleted = tablesQuery.cells.staticTexts[uiTestItemName]
        XCTAssertFalse(deleted.exists)
        
        app.navigationBars[editCustomItem].buttons["Done"].tap()
        app.buttons["baseline more horiz black 36pt"].tap()
        app.sheets["menu".localized(for: tester)].buttons[editCustomItem].tap()
        app.navigationBars[editCustomItem].buttons["Done"].tap()
        app.navigationBars["errandFoods".localized(for: tester)].buttons["Cancel"].tap()
    }

}
