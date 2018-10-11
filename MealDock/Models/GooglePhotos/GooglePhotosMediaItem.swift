//
//  GooglePhotosMediaItem.swift
//  MealDock
//
//  Created by Wataru Suzuki 2018/10/11.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation

struct GooglePhotosMediaItem: Codable {
    let id: String
    let productUrl: String
    let description: String
    let mediaMetadata: GooglePhotosMediaMetadata
    //Note: It's different between reference & test
    var baseUrl: String?
    var mimeType: String?
}
/*
"mediaItem": {
    "id": "MEDIA_ITEM_ID",
    "productUrl": "https://photos.google.com/photo/PHOTO_PATH",
    "description": "ITEM_DESCRIPTION",
    "baseUrl": "BASE_URL-DO_NOT_USE_DIRECTLY",
    "mediaMetadata": {
        "width": "MEDIA_WIDTH_IN_PX",
        "height": "MEDIA_HEIGHT_IN_PX",
        "creationTime": "CREATION_TIME",
        "photo": {}
    },
}
*/
