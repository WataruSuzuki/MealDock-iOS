//
//  DeepLinkTestCase.swift
//  MealDockTests
//
//  Created by Wataru Suzuki on 2019/01/08.
//  Copyright © 2019 WataruSuzuki. All rights reserved.
//

import XCTest
@testable import MealDock

class DeepLinkTestCase: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateDeepLink() {
        FirebaseService.DeepLinkExtra.allCases.forEach { (extra) in
            let deepLinkUrl = FirebaseService.shared.createDeepLink(extra: extra.rawValue)
            XCTAssertNotNil(deepLinkUrl)
            XCTAssertTrue(deepLinkUrl!.absoluteString.contains(extra.rawValue.replacingOccurrences(of: "/", with: "")))
        }
    }

}
