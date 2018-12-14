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

    func testHandleDeepLink() {
        FirebaseService.DeepLinkExtra.allCases.forEach { (extra) in
            let path = extra.rawValue.replacingOccurrences(of: "/", with: "")
            let url = "https://devjchankchan.page.link/?link=https%3A%2F%2Fexample%2Ddevjchankchan%2Efirebaseapp%2Ecom%2F" + path + "&ibi=jp%2Eco%2EJchanKchan%2EMealDock%2Edev&apn=dev%2Ejchankchan%2Emealdock%2Eapp"

            let isDeepLink = FirebaseService.shared.handleUniversalLink(webpageURL: URL(string: url)!) { (link, error) in
                XCTAssertNil(error)
                XCTAssertTrue(link!.url!.absoluteString.contains(path))
            }
            XCTAssertTrue(isDeepLink)
        }
    }
}
