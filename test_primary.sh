xcodebuild clean test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone XS Max' \
    -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (3rd generation)' \
    > test_primary.log
