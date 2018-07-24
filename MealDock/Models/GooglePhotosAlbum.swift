//
//  GooglePhotosAlbum.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/11.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation

struct GooglePhotosAlbum: Codable {
    let id: String
    let title: String
    let productUrl: String
    var isWriteable: String?
}
/*
{
    "productUrl": "URL_TO_OPEN_IN_GOOGLE_PHOTOS",
    "id": "ALBUM_ID",
    "title": "New Album Title",
    "isWriteable": "WHETHER_YOU_CAN_WRITE_TO_THIS_ALBUM"
}
*/
