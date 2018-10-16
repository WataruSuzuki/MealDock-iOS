//
//  OptionalError.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/13.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit

class OptionalError: NSError {

    init(with type: ErrorType, userInfo: [String : Any]?) {
        super.init(domain: Bundle.main.bundleIdentifier ?? "(・w・)", code: type.rawValue, userInfo: userInfo)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func kaomojiErrorStr(funcName: String) -> String {
        return "(・A・)!! " + funcName
    }
    
    enum ErrorType: Int {
        case unknown = 600,
        cannotGetToken
    }
}
