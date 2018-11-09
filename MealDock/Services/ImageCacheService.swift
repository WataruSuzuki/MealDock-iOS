//
//  ImageCacheService.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/11/06.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit
import AlamofireImage

class ImageCacheService: NSObject {
    static let shared: ImageCacheService = {
        return ImageCacheService()
    }()
    
    private override init() {
        let cache = URLCache(
            memoryCapacity: 0, diskCapacity: 1000 * 1024 * 1024,  // 1 GB
            diskPath: "org.alamofire.imagedownloader"
        )
        URLCache.shared = cache
    }

    let imageCache = AutoPurgingImageCache(
        memoryCapacity: 100 * 1024 * 1024,  // 100 MB
        preferredMemoryUsageAfterPurge: 60 * 1024 * 1024 // 60 MB
    )
}
