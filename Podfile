platform :ios, "9.0"
#inhibit_all_warnings!
use_frameworks!

target "MealDock" do
    pod 'Alamofire', '~> 4.7'
    pod 'AlamofireImage', '~> 3.4'
    pod 'DJKFlatIconAuthors', :git => 'https://github.com/WataruSuzuki/DJKFlatIconAuthors.git'
    pod 'DJKUtilities', :git => 'https://github.com/WataruSuzuki/DJKUtilities.git'
    pod 'DJKUtilAdMob', :git => 'https://github.com/WataruSuzuki/DJKUtilAdMob.git'#, :configuration => ["Release"]
    pod 'DJKInAppPurchase', :git => 'https://github.com/WataruSuzuki/DJKInAppPurchase.git'#, :configuration => ["Release"]
    pod 'Firebase/Core'
    pod 'Firebase/Messaging'
    pod 'Firebase/AdMob'
    pod 'FirebaseUI'
    pod 'CodableFirebase'
    pod 'PersonalizedAdConsent'
    pod 'GoogleMobileAdsMediationNend'
    pod 'DZNEmptyDataSet'
    pod 'MaterialComponents'
    pod 'SimpleKeychain'
    pod 'PureLayout'
    pod 'TinyConstraints'
    pod 'Parchment'
end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-MealDock/Pods-MealDock-acknowledgements.plist', 'MealDock/Settings.bundle/Pods-acknowledgements.plist')
end