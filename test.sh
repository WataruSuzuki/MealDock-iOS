xcodebuild test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone XS Max' \
    -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (2nd generation)' \

xcodebuild test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPad Pro (10.5-inch),OS=11.4' \
    -destination 'platform=iOS Simulator,name=iPhone X,OS=11.4' \

xcodebuild test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPad Air 2,OS=10.3.1' \
    -destination 'platform=iOS Simulator,name=iPhone 7 Plus,OS=10.3.1' \

xcodebuild test -workspace MealDock.xcworkspace -scheme MealDock -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 5s,OS=9.3' \
    -destination 'platform=iOS Simulator,name=iPhone 6,OS=10.3.1' \
