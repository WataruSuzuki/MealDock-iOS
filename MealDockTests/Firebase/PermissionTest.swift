//
//  PermissionTest.swift
//  MealDockTests
//
//  Created by Wataru Suzuki on 2018/10/10.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import XCTest
@testable import MealDock
import Firebase

class PermissionTest: XCTestCase {

    var ref: DatabaseReference!
    var user: User!
    
//    override func setUp() {
//        FirebaseApp.configure()
//        ref = Database.database().reference()
//        Auth.auth().signIn(withEmail: MealDockTests.emailEmptyUser, password: MealDockTests.password) { (result, error) in
//            if let signInUser = result?.user {
//                self.user = signInUser
//            }
//        }
//        MealDockTests.waitingSec(sec: 10.0, sender: self)
//    }
//
//    override func tearDown() {
//        try? Auth.auth().signOut()
//    }

    func testCorrectObserving() {        
        // I'll check at UI Test
    }
    /*
    func testObservingViaWrongUid() {
        let wrongId = "(=・∀・=)"
        failObserve(id: wrongId, itemId: FirebaseService.ID_MARKET_ITEMS)
        failObserve(id: wrongId, itemId: FirebaseService.ID_CARTED_ITEMS)
        failObserve(id: wrongId, itemId: FirebaseService.ID_FRIDGE_ITEMS)
        failObserve(id: wrongId, itemId: FirebaseService.ID_DISH_ITEMS)
    }
    
    fileprivate func failObserve(id: String, itemId : String) {
        weak var expectation = self.expectation(description: itemId)
        ref.child(itemId).child(id).observe(.value, with: { (snapshot) in
            print(snapshot)
            XCTAssertNotNil(snapshot.value)
            expectation?.fulfill()
        }) { (error) in
            XCTAssertNotNil(error)
            expectation?.fulfill()
        }
        self.waitForExpectations(timeout: 3.00, handler: nil)
    }

    func testObservingMealDockRoom() {
        let itemId = FirebaseService.ID_MEAL_DOCKS
        weak var expectation = self.expectation(description: itemId)
        ref.child(itemId).observe(.value, with: { (snapshot) in
            debugPrint(snapshot)
            XCTFail("(・A・)!! testObservingMealDockRoom \(itemId)")
        }) { (error) in
            XCTAssertNotNil(error)
            expectation?.fulfill()
        }
        self.waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testFailToObserveRootItems() {
        failObserve(id: user.uid, itemId: FirebaseService.ID_MARKET_ITEMS)
        failObserve(id: user.uid, itemId: FirebaseService.ID_CARTED_ITEMS)
        failObserve(id: user.uid, itemId: FirebaseService.ID_FRIDGE_ITEMS)
        failObserve(id: user.uid, itemId: FirebaseService.ID_DISH_ITEMS)
    }*/
}
