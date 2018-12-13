//
//  Firebase+DeepLink.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/12/26.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import FirebaseDynamicLinks

extension FirebaseService {
    static let deepLink = "https://example-devjchankchan.firebaseapp.com"
    static let deepLinkHost = "devjchankchan.page.link"
    static let deepLinkAppStoreId = "1447468603"
    
    enum DeepLinkExtra: String, CaseIterable {
        case dishes = "/dishes",
        inFridgeFoods = "/infridgefoods",
        cartedFoods = "/cartedfoods"
    }

    func handleUniversalLink(webpageURL: URL) -> Bool {
        return DynamicLinks.dynamicLinks().handleUniversalLink(webpageURL) { dynamiclink, error in
            guard let dynamiclink = dynamiclink, let url = dynamiclink.url else { return }
            
            debugPrint("url:", url)
            if let extra = DeepLinkExtra(rawValue: url.absoluteString.replacingOccurrences(of: FirebaseService.deepLink, with: "")) {
                var targetTab = InitViewController.TabItem.dishes
                switch extra {
                case .dishes:
                    break
                case .inFridgeFoods:
                    targetTab = InitViewController.TabItem.inFridgeFoods
                case .cartedFoods:
                    targetTab = InitViewController.TabItem.cartedFoods
                }
                InitViewController.switchTab(to: targetTab)
            }
        }
    }
    
    func createDeepLink(extra: String) -> URL? {
        guard let link = URL(string: FirebaseService.deepLink + extra) else { return nil }
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: "https://" + FirebaseService.deepLinkHost)
        
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: Bundle.main.bundleIdentifier!)
        //linkBuilder?.iOSParameters?.appStoreID = FirebaseService.deepLinkAppStoreId
        //linkBuilder?.iOSParameters?.minimumAppVersion = "1.0.1"
        
        linkBuilder?.androidParameters = DynamicLinkAndroidParameters(packageName: "dev.jchankchan.mealdock.app")
        //linkBuilder?.androidParameters?.minimumVersion = 1
        /*
        linkBuilder?.analyticsParameters = DynamicLinkGoogleAnalyticsParameters(source: "orkut",
                                                                               medium: "social",
                                                                               campaign: "example-promo")
        
        linkBuilder?.iTunesConnectParameters = DynamicLinkItunesConnectAnalyticsParameters()
        linkBuilder?.iTunesConnectParameters?.providerToken = "123456"
        linkBuilder?.iTunesConnectParameters?.campaignToken = "example-promo"
        
        linkBuilder?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkBuilder?.socialMetaTagParameters?.title = "Example of a Dynamic Link"
        linkBuilder?.socialMetaTagParameters?.descriptionText = "This link works whether the app is installed or not!"
        linkBuilder?.socialMetaTagParameters?.imageURL = URL(string: "https://www.example.com/my-image.jpg")
        */
        guard let longDynamicLink = linkBuilder?.url else { return nil }
        print("The long URL is: \(longDynamicLink)")
        return longDynamicLink
    }
}
