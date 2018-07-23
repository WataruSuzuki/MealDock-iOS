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
        // I'll check at UI Test
    }
    
    func testObservingViaWrongUid() {
        let wrongId = "(=・∀・=)"
        failObserve(wrongUid: wrongId, itemId: FirebaseService.ID_CARTED_ITEMS)
        failObserve(wrongUid: wrongId, itemId: FirebaseService.ID_FRIDGE_ITEMS)
        failObserve(wrongUid: wrongId, itemId: FirebaseService.ID_DISH_ITEMS)
    }
    
    fileprivate func failObserve(wrongUid: String, itemId : String) {
        let expectation = self.expectation(description: itemId)
        ref.child(itemId).child(wrongUid).observe(.value, with: { (snapshot) in
            print(snapshot)
            XCTFail("(・A・)!! testFailToObserveRoots \(itemId)")
        }) { (error) in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3.00, handler: nil)
    }

    func testObservingMealDockRoom() {
        let itemId = FirebaseService.ID_MEAL_DOCKS
        observeSuccess(itemId: itemId)
    }
    
    fileprivate func observeSuccess(itemId : String) {
        let expectation = self.expectation(description: itemId)
        ref.child(itemId).observe(.value, with: { (snapshot) in
            debugPrint(snapshot)
            expectation.fulfill()
        }) { (error) in
            XCTFail("(・A・)!! testFailToObserveRoots \(itemId)")
        }
        self.waitForExpectations(timeout: 3.00, handler: nil)
    }

    func testFailToObserveRootItems() {
        failObserve(itemId: FirebaseService.ID_CARTED_ITEMS)
        failObserve(itemId: FirebaseService.ID_FRIDGE_ITEMS)
        failObserve(itemId: FirebaseService.ID_DISH_ITEMS)
    }
    
    fileprivate func failObserve(itemId : String) {
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
