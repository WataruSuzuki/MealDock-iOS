#bin/sh

cd `dirname $0`

rm MealDock/TestFlight-Info.plist
sed -e "s/\<key\>LSRequiresIPhoneOS\<\/key\>/\<key\>ITSAppUsesNonExemptEncryption\<\/key\>\<false\/\>\<key\>LSRequiresIPhoneOS\<\/key\>/g" ./MealDock/Info.plist > ./MealDock/TestFlight-Info.plist
