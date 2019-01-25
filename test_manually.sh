xcodebuild test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPad Pro (10.5-inch),OS=10.3.1' \
    > test_os10_pad.log

xcodebuild test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 7 Plus,OS=10.3.1' \
    > test_os10_phone.log
