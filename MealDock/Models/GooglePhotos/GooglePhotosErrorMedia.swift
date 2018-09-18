//
//  GooglePhotosErrorMedia.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/28.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation

struct GooglePhotosErrorMedia: Codable {
    let error: ErrorMedia
}

struct ErrorMedia: Codable {
    let code: Int
    let status: String
    var message: String?
}

