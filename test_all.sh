./test_primary.sh

xcodebuild test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone X,OS=11.4' \
    > test_os11_phone.log

xcodebuild test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPad (6th generation),OS=11.4' \
    > test_os11_pad.log

xcodebuild test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPad Pro (10.5-inch),OS=10.3.1' \
    > test_os10_pad.log

xcodebuild test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 7 Plus,OS=10.3.1' \
    > test_os10_phone.log

xcodebuild test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 6,OS=9.3'

# xcodebuild test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
#     -destination 'platform=iOS Simulator,name=iPhone 4s,OS=9.3'
