//
//  PurchaseService.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/19.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import GoogleMobileAds

class PurchaseService: NSObject {
    static let shared: PurchaseService = {
        return PurchaseService()
    }()
    var adLoader: GADAdLoader?
    var loadedNativeAd = [GADUnifiedNativeAd]()
    var nativeViews = Set<GADUnifiedNativeAdView>()
    
    var isPurchased: Bool {
        get {
            return false
        }
    }
    var productRequest: SKProductsRequest?
    var productResponse: SKProductsResponse?
    var productIDs = Set<String>()
    
}
