./test_primary.sh

xcodebuild test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPad (5th generation) (11.4)' \
    -destination 'platform=iOS Simulator,name=iPhone X (11.4)' \
    > test_os11.log

xcodebuild test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPad Pro (10.5-inch) (10.3.1)' \
    -destination 'platform=iOS Simulator,name=iPhone 7 Plus (10.3.1)' \
    > test_os10.log

xcodebuild test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 4s (9.3)' \
    -destination 'platform=iOS Simulator,name=iPhone 6 (9.3)' \
