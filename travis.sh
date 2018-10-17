xcodebuild clean test -workspace MealDock.xcworkspace \
-scheme MealDock -sdk iphonesimulator \
-destination 'platform=iOS Simulator,name=iPhone XS Max' \
> unittest.log
