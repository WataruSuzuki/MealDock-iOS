xcodebuild clean test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone XS Max' \
    > test_primary_phone.log

# xcodebuild test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
#     -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (3rd generation)' \
#     > test_primary_pad.log
