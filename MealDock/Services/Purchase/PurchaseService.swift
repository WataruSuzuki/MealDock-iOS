//
//  PurchaseService.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/19.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import GoogleMobileAds

class PurchaseService: NSObject,
    GADUnifiedNativeAdDelegate,
    GADVideoControllerDelegate,
    GADUnifiedNativeAdLoaderDelegate,
    GADAdLoaderDelegate
{
    static let shared: PurchaseService = {
        return PurchaseService()
    }()
    var adLoader: GADAdLoader?
    var loadedNativeAd = [GADUnifiedNativeAd]()
    var nativeViews = Set<GADUnifiedNativeAdView>()
    
    // MARK: - GADUnifiedNativeAdLoaderDelegate
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        loadedNativeAd.append(nativeAd)
        if let adView = nativeViews.first {
            applyNativeAd(view: adView)
            nativeViews.remove(adView)
        }
        
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
        // The native ad was shown.
    }
    
    func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
        // The native ad was clicked on.
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
        // The native ad will present a full screen view.
    }
    
    func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
        // The native ad will dismiss a full screen view.
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
        // The native ad did dismiss a full screen view.
    }
    
    func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
        // The native ad will cause the application to become inactive and
        // open a new application.
    }
    
    // MARK: - GADAdLoaderDelegate
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        
    }
    
    func load(unitId: String, controller: UIViewController) {
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 5
        
        #if DEBUG
        let adUnitId = "ca-app-pub-3940256099942544/3986624511"
        #else
        let adUnitId = unitId
        #endif
        
        adLoader = GADAdLoader(adUnitID: adUnitId, rootViewController: controller,
                               adTypes: [GADAdLoaderAdType.unifiedNative],
                               options: [multipleAdsOptions])
        adLoader?.delegate = self
        adLoader?.load(GADRequest())
    }
    
    func nativeView() -> UIView? {
        if let nibObjects = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil),
            let adView = nibObjects.first as? GADUnifiedNativeAdView {
            nativeViews.update(with: adView)
            return adView
        }
        return nil
    }
    
    func applyNativeAd(view: UIView) -> Bool {
        guard let nativeView = view as? GADUnifiedNativeAdView, loadedNativeAd.count > 0, let nativeAd = loadedNativeAd.first else {
            return false
        }
        loadedNativeAd.removeFirst()
        nativeView.nativeAd = nativeAd
        
        // Set ourselves as the native ad delegate to be notified of native ad events.
        nativeAd.delegate = self
        
        // Populate the native ad view with the native ad assets.
        // Some assets are guaranteed to be present in every native ad.
        (nativeView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeView.bodyView as? UILabel)?.text = nativeAd.body
        (nativeView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        // Some native ads will include a video asset, while others do not. Apps can use the
        // GADVideoController's hasVideoContent property to determine if one is present, and adjust their
        // UI accordingly.
        if let controller = nativeAd.videoController, controller.hasVideoContent() {
            // The video controller has content. Show the media view.
            if let mediaView = nativeView.mediaView {
                // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
                // ratio of the video it displays.
            }
            // By acting as the delegate to the GADVideoController, this ViewController receives messages
            // about events in the video lifecycle.
            controller.delegate = self
        }
        // These assets are not guaranteed to be present, and should be checked first.
        (nativeView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        if let _ = nativeAd.icon {
            nativeView.iconView?.isHidden = false
        } else {
            nativeView.iconView?.isHidden = true
        }
        //(nativeView?.starRatingView as? UIImageView)?.image = imageOfStars(from:nativeAd.starRating)
//        if let _ = nativeAd.starRating {
//            nativeView.starRatingView?.isHidden = false
//        }
//        else {
            nativeView.starRatingView?.isHidden = true
//        }
        (nativeView.storeView as? UILabel)?.text = nativeAd.store
        if let _ = nativeAd.store {
            nativeView.storeView?.isHidden = false
        }
        else {
            nativeView.storeView?.isHidden = true
        }
        (nativeView.priceView as? UILabel)?.text = nativeAd.price
        if let _ = nativeAd.price {
            nativeView.priceView?.isHidden = false
        }
        else {
            nativeView.priceView?.isHidden = true
        }
        (nativeView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        if let _ = nativeAd.advertiser {
            nativeView.advertiserView?.isHidden = false
        }
        else {
            nativeView.advertiserView?.isHidden = true
        }
        // In order for the SDK to process touch events properly, user interaction should be disabled.
        nativeView.callToActionView?.isUserInteractionEnabled = false

        return true
    }
}
