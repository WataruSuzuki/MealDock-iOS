//
//  PermissionTest.swift
//  MealDockTests
//
//  Created by 鈴木 航 on 2018/10/10.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import XCTest
@testable import MealDock

class PermissionTest: XCTestCase {

    var ref: DatabaseReference!
    var user: User!
    
    override func setUp() {
        let expectation: XCTestExpectation? = self.expectation(description: "setUp")
        Auth.auth().signIn(withEmail: MealDockTests.email, password: MealDockTests.password) { (result, error) in
            if let signInUser = result?.user {
                self.user = signInUser
                expectation?.fulfill()
            }
        }
        self.waitForExpectations(timeout: 5.00, handler: nil)
        ref = Database.database().reference()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCorrectObserving() {        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testFailToObserveRootItems() {
        observeRoot(itemId: FirebaseService.ID_CARTED_ITEMS)
        observeRoot(itemId: FirebaseService.ID_FRIDGE_ITEMS)
        observeRoot(itemId: FirebaseService.ID_DISH_ITEMS)
    }
    
    fileprivate func observeRoot(itemId : String) {
        let expectation = self.expectation(description: itemId)
        ref.child(itemId).observe(.value, with: { (snapshot) in
            print(snapshot)
            XCTFail("(・A・)!! testFailToObserveRoots \(itemId)")
        }) { (error) in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3.00, handler: nil)
    }
}
