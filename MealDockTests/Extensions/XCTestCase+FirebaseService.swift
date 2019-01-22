//
//  XCTestCase+FirebaseService.swift
//  MealDockTests
//
//  Created by WataruSuzuki on 2019/01/24.
//  Copyright © 2019 WataruSuzuki. All rights reserved.
//

import XCTest
@testable import MealDock

extension XCTestCase {
    static let email_member_unittest = "member_unittest@mealdock.com"
    static let password = "unittest"
    
    func setupAsGroupMember() {
        waitingSec(sec: 5, sender: self)

        if FirebaseService.shared.isSignOn {
            return
        }
        Auth.auth().signIn(withEmail: XCTestCase.email_member_unittest, password: XCTestCase.password) { (result, error) in
        }
        FirebaseService.shared.waitSignIn {
            //do nothing
        }
        waitingSec(sec: 5, sender: self)
    }
    
    func tearDownWithGroupMember() {
        if FirebaseService.shared.isSignOn {
            FirebaseService.shared.signOut()
            waitingSec(sec: 2, sender: self)
        }
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
