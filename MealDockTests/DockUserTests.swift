//
//  DockUserTests.swift
//  MealDockTests
//
//  Created by Wataru Suzuki on 2019/01/24.
//  Copyright © 2019 WataruSuzuki. All rights reserved.
//

import XCTest
@testable import MealDock

class DockUserTests: XCTestCase {

    override func setUp() {
        super.setUp()
        setupAsGroupMember()
    }

    override func tearDown() {
        tearDownWithGroupMember()
        super.tearDown()
    }

    func testCapacity() {
        let service = FirebaseService.shared
        let max = UsageInfo.PurchasePlan.max.limitSize() / UsageInfo.PurchasePlan.max.rawValue
        
        service.itemCounters.updateValue(max, forKey: FirebaseService.ID_MARKET_ITEMS)
        service.itemCounters.updateValue(max, forKey: FirebaseService.ID_CARTED_ITEMS)
        service.itemCounters.updateValue(max, forKey: FirebaseService.ID_FRIDGE_ITEMS)
        
        XCTAssertFalse(service.currentUser!.hasCapacity(addingSize: max))
        waitingSec(sec: 3, sender: self)
        
        XCTAssertTrue(service.currentUser!.hasCapacity(addingSize: 1))
    }

}
