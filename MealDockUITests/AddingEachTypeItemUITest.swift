//
//  InFridgeListSceneUITest.swift
//  MealDockUITests
//
//  Created by Wataru Suzuki on 2019/01/21.
//  Copyright © 2019 WataruSuzuki. All rights reserved.
//

import XCTest

class AddingEachTypeItemUITest: XCTestCase {
    private let tester = AddingEachTypeItemUITest.self

    override func setUp() {
        super.setUp()
        setupAsGroupMember(app: XCUIApplication())
    }
    
    override func tearDown() {
        //tearDownWithGroupMember()
        super.tearDown()
    }

    func testAddCartToFridge() {
        let app = XCUIApplication()
        app.tabBars.buttons["cartedFoods".localized(for: tester)].tap()
        
        let addButton = app.navigationBars["cartedFoods".localized(for: tester)].buttons["Add"]
        addButton.tap()
        
        let skipAd = app.webViews.buttons["Skip Ad"]
        if skipAd.exists {
            skipAd.tap()
            waitingSec(sec: 1.0, sender: self)
            addButton.tap()
        }
        
        app.scrollViews.otherElements.collectionViews.cells.containing(.staticText, identifier:"asparagus".foodName(for: tester)).children(matching: .other).element.tap()
        
        let errandFoodsNavigationBar = app.navigationBars["Errand Foods"]
        errandFoodsNavigationBar.buttons["Done"].tap()
        
        let tablesQuery = app.tables
        let incrementAsparagus = tablesQuery.cells.containing(.staticText, identifier:"asparagus".foodName(for: tester)).buttons["Increment"]
        incrementAsparagus.tap()
        incrementAsparagus.tap()
        
        tablesQuery.buttons["freezer"].tap()
        waitingSec(sec: 1.0, sender: self)
    }
    
    func testAddDish() {
        let app = XCUIApplication()
        app.tabBars.buttons["inFridgeFoods".localized(for: tester)].tap()
        
        let tablesQuery = app.tables
        tablesQuery.cells.containing(.staticText, identifier: "asparagus".foodName(for: tester)).buttons["Increment"].tap()
        app.tables.buttons["dish"].tap()
        
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .collectionView).element.swipeUp()

        let collectionViewsQuery = app.collectionViews
        let titleTextField = collectionViewsQuery.textFields["title".localized(for: tester)]
        titleTextField.tap()
        titleTextField.inputText(text: uiTestItemName)
        
        let descriptionTextView = collectionViewsQuery.otherElements["description".localized(for: tester)].children(matching: .textView).element
        descriptionTextView.tap()
        descriptionTextView.inputText(text: "Hoge Hoge Fuga Fuga")
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            //Do nothing
        } else {
            let cell = collectionViewsQuery.children(matching: .cell).element(boundBy: 0)
            cell.children(matching: .other).element.swipeUp()
            cell.children(matching: .other).element(boundBy: 0).swipeUp()
        }
        app.buttons["dish"].tap()
    }

}
