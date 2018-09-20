//
//  MealDockUITests.swift
//  MealDockUITests
//
//  Created by 鈴木 航 on 2018/07/30.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import XCTest

class MealDockUITests: XCTestCase {
    static let email = "member_unittest@mealdock.com"
    static let password = "unittest"
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        signInByGroupMember()
        MealDockUITests.waitingSec(sec: 3.0, sender: self)
    }
    
    private func signInByGroupMember() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        
        let emailTextField = tablesQuery/*@START_MENU_TOKEN@*/.textFields["Enter your email"]/*[[".cells[\"EmailCellAccessibilityID\"].textFields[\"Enter your email\"]",".textFields[\"Enter your email\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        emailTextField.tap()
        emailTextField.typeText(MealDockUITests.email)
        
        app.navigationBars["Enter your email"]/*@START_MENU_TOKEN@*/.buttons["NextButtonAccessibilityID"]/*[[".buttons[\"Next\"]",".buttons[\"NextButtonAccessibilityID\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let passwordTextField = tablesQuery/*@START_MENU_TOKEN@*/.secureTextFields["Enter your password"]/*[[".cells.secureTextFields[\"Enter your password\"]",".secureTextFields[\"Enter your password\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        passwordTextField.tap()
        passwordTextField.typeText(MealDockUITests.password)
        app.navigationBars["Sign in"].buttons["Sign in"].tap()
    }
    
    private func signOut() {
        XCUIApplication().tabBars.buttons["Settings"].tap()
        XCUIApplication().tables/*@START_MENU_TOKEN@*/.staticTexts["Sign out"]/*[[".cells.staticTexts[\"Sign out\"]",".staticTexts[\"Sign out\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    }

    override func tearDown() {
        signOut()
        MealDockUITests.waitingSec(sec: 3.0, sender: self)
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    class func waitingSec(sec: Double, sender: XCTestCase) {
        let expectation = sender.expectation(description: "Waiting")
        DispatchQueue.main.asyncAfter(deadline: .now() + sec) {
            expectation.fulfill()
        }
        sender.waitForExpectations(timeout: (TimeInterval(sec + 2))) { (error) in
            //do nothing
        }
    }
    
}
