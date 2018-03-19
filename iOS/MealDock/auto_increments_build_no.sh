#!/bin/bash
APP_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $PRODUCT_SETTINGS_PATH)
/usr/libexec/PlistBuddy -c "Set :PreferenceSpecifiers:1:DefaultValue ${APP_VERSION}" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Settings.bundle/Root.plist"

APP_BUILD_NO=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" $PRODUCT_SETTINGS_PATH)
/usr/libexec/PlistBuddy -c "Set :PreferenceSpecifiers:2:DefaultValue ${APP_BUILD_NO}" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Settings.bundle/Root.plist"

if [ "${CONFIGURATION}" = "Release" ]; then

    # get the build number
    buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFOPLIST_FILE")
    echo "Old Build number $buildNumber"

    # split it by dots
    arrIN=(${buildNumber/./ })

    # get the last element position
    lastElementPosition=$((${#arrIN[@]} - 1))
    # get the minor version from the last array element
    minorVersion=${arrIN[${lastElementPosition}]}
    # Increase it by 1
    minorVersion=$((minorVersion+1))
    # Format it as 3 digit
    #minorVersion=`printf "%03d" $minorVersion`
    echo "New minor version $minorVersion"
    # Update it on the array
    arrIN[$lastElementPosition]=$minorVersion

    # construct the build number now by joining the array
    buildNumber=$(IFS=. ; echo "${arrIN[*]}")

    echo "New Build number $buildNumber"

    #update it in plist
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$INFOPLIST_FILE"

fi
