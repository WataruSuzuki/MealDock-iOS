//
//  GooglePhotosErrorMediaItem.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/27.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation

struct GooglePhotosErrorMediaItem: Codable {
    let error: ErrorMedia
}

struct ErrorMedia: Codable {
    let code: Int
    let status: String
    var message: String?
}
