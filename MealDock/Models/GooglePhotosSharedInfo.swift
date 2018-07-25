//
//  GooglePhotosSharedInfo.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/12.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation

struct GooglePhotosSharedInfo: Codable {
    let shareableUrl: String
    let shareToken: String
    var isJoined: Int?
    //let sharedAlbumOptions: [String: Any]
}
