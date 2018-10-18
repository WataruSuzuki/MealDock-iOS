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
        app.tabBars.buttons["Carted Foods"].tap()
        app.navigationBars["Carted Foods"].buttons["Add"].tap()
        
        app.buttons["Add new Market Item"].tap()
        
        let titleTextField = app.collectionViews/*@START_MENU_TOKEN@*/.textFields["Title"]/*[[".cells.textFields[\"Title\"]",".textFields[\"Title\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        titleTextField.inputText(text: ErrandSceneUITests.itemName)
        
        app.collectionViews.children(matching: .cell).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element.tap()
        
        let pickerWheel = app/*@START_MENU_TOKEN@*/.pickerWheels["🍚🍞🍙🥖🍜🍝"]/*[[".pickers.pickerWheels[\"🍚🍞🍙🥖🍜🍝\"]",".pickerWheels[\"🍚🍞🍙🥖🍜🍝\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        pickerWheel.tap()
        app.toolbars["Toolbar"].buttons["Done"].tap()
        app.navigationBars["Add new Market Item"].buttons["Save"].tap()
        
        app.collectionViews/*@START_MENU_TOKEN@*/.staticTexts["🍚🍞🍙🥖🍜🍝"]/*[[".cells.staticTexts[\"🍚🍞🍙🥖🍜🍝\"]",".staticTexts[\"🍚🍞🍙🥖🍜🍝\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.scrollViews.otherElements.collectionViews.cells.containing(.staticText, identifier:ErrandSceneUITests.itemName).children(matching: .other).element.tap()
        app.navigationBars["Errand Foods"].buttons["Done"].tap()
    }

}
