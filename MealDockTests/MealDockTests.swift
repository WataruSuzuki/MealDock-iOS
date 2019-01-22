//
//  MealDockTests.swift
//  MealDockTests
//
//  Created by Wataru Suzuki on 2018/07/30.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import XCTest
@testable import MealDock

class MealDockTests: XCTestCase {
    
    static let email = "unittest@mealdock.com"
    static let emailEmptyUser = "empty_unittest@mealdock.com"
    static let emptyUserPassword = "unittest"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    class func waitingSec(sec: Double, sender: XCTestCase) {
        weak var expectation = sender.expectation(description: "Waiting")
        DispatchQueue.main.asyncAfter(deadline: .now() + sec) {
            expectation?.fulfill()
        }
        sender.waitForExpectations(timeout: (TimeInterval(sec + 2))) { (error) in
            //do nothing
        }
    }
}
