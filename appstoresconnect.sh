PROJ_FILE_PATH="MealDock.xcworkspace"
OUT_ARCHIVES_DIR="out_archives"
OUT_IPA_DIR="out_ipa"
ITUNES_ID="devjchankchan@gmail.com"
ITUNES_PW="igug-meqh-ycur-xbgc"
ALTTOOL="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Support/altool"

# 出力先ipaディレクトリ作成
# -------------------------
if [ ! -d ${OUT_ARCHIVES_DIR} ]
then
    mkdir "${OUT_ARCHIVES_DIR}"
fi
if [ ! -d ${OUT_IPA_DIR} ]
then
    mkdir "${OUT_IPA_DIR}"
fi

# 関数の定義
# -------------------------
appstore_connect () {
    xcodebuild clean -workspace "${PROJ_FILE_PATH}"
    xcodebuild archive -workspace "${PROJ_FILE_PATH}" -scheme $1 -archivePath "${PWD}/${OUT_ARCHIVES_DIR}/$1.xcarchive" -configuration $2
    xcodebuild -exportArchive -archivePath "${PWD}/${OUT_ARCHIVES_DIR}/$1.xcarchive" -exportPath "${PWD}/${OUT_IPA_DIR}" -exportOptionsPlist "${PWD}/exportOptions.Plist"
    "${ALTTOOL}" --validate-app -f "${PWD}/${OUT_IPA_DIR}/$1.ipa"  -u ${ITUNES_ID} -p ${ITUNES_PW}
    "${ALTTOOL}" --upload-app -f "${PWD}/${OUT_IPA_DIR}/$1.ipa"  -u ${ITUNES_ID} -p ${ITUNES_PW}
}

#Release
appstore_connect MealDock Release
