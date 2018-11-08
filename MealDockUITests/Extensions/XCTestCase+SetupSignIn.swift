//
//  XCTestCase+SetupSignIn.swift
//  MealDockUITests
//
//  Created by Wataru Suzuki on 2018/11/08.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import XCTest

extension XCTestCase {
    static let email = "member_unittest@mealdock.com"
    static let password = "unittest"

    func setupAsGroupMember(app: XCUIApplication) {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app.launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        signInByGroupMember(app: app)
        waitingSec(sec: 10.0, sender: self)
    }
    
    func tearDownWithGroupMember() {
        signOut()
        waitingSec(sec: 5.0, sender: self)
    }
    
    func signInByGroupMember(app: XCUIApplication) {
        let tablesQuery = app.tables
        
        let emailTextField = tablesQuery/*@START_MENU_TOKEN@*/.textFields["Enter your email"]/*[[".cells[\"EmailCellAccessibilityID\"].textFields[\"Enter your email\"]",".textFields[\"Enter your email\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        emailTextField.inputText(text: XCTestCase.email)
        
        app.navigationBars["Enter your email"]/*@START_MENU_TOKEN@*/.buttons["NextButtonAccessibilityID"]/*[[".buttons[\"Next\"]",".buttons[\"NextButtonAccessibilityID\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let passwordTextField = tablesQuery/*@START_MENU_TOKEN@*/.secureTextFields["Enter your password"]/*[[".cells.secureTextFields[\"Enter your password\"]",".secureTextFields[\"Enter your password\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        passwordTextField.tap()
        passwordTextField.typeText(XCTestCase.password)
        app.navigationBars["Sign in"].buttons["Sign in"].tap()
    }
    
    func signOut() {
        XCUIApplication().tabBars.buttons["Settings"].tap()
        XCUIApplication().tables/*@START_MENU_TOKEN@*/.staticTexts["Sign out"]/*[[".cells.staticTexts[\"Sign out\"]",".staticTexts[\"Sign out\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    }
    
    func waitingSec(sec: Double, sender: XCTestCase) {
        weak var expectation = sender.expectation(description: "Waiting")
        DispatchQueue.main.asyncAfter(deadline: .now() + sec) {
            expectation?.fulfill()
        }
        sender.waitForExpectations(timeout: (TimeInterval(sec + 2))) { (error) in
            //do nothing
        }
    }
}
