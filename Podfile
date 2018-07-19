platform :ios, "9.0"
#inhibit_all_warnings!
use_frameworks!

target "MealDock" do
    pod 'Alamofire', '~> 4.7'
    pod 'AlamofireImage', '~> 3.4'
    pod 'OAuthSwiftAlamofire'
    pod 'DJKFlatIconAuthors', :git => 'https://github.com/WataruSuzuki/DJKFlatIconAuthors.git'
    pod 'DJKUtilities', :git => 'https://github.com/WataruSuzuki/DJKUtilities.git'
    pod 'DJKUtilAdMob', :git => 'https://github.com/WataruSuzuki/DJKUtilAdMob.git'#, :configuration => ["Release"]
    pod 'DJKInAppPurchase', :git => 'https://github.com/WataruSuzuki/DJKInAppPurchase.git'#, :configuration => ["Release"]
    pod 'Firebase/AdMob'
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'Firebase/Storage'
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
    pod 'AppAuth'

    platform :ios, '10.0'
        pod 'OAuthSwift', '~> 1.2.0'

    target 'MealDockTests' do
        inherit! :search_paths
        # pod 'Firebase'
    end
end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-MealDock/Pods-MealDock-acknowledgements.plist', 'MealDock/Settings.bundle/Pods-acknowledgements.plist')
end
