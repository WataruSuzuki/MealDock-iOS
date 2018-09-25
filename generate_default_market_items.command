#!/bin/sh

declare -a gabages=(
    default_market_items.json
    d2json.js
)

function remove_unnecessaries () {
    for ((i = 0; i < ${#gabages[@]}; i++)) {
        sed -e "s/{\"file\":\"${gabages[i]}\",\"section\":\".\",\"imageUrl\":\"https\:\/\/watarusuzuki.github.io\/MealDock\/images\/.\/${gabages[i]}\",\"timeStamp\":0},//g" ./default_market_items.json > ./data-new.json

        rm default_market_items.json
        mv data-new.json default_market_items.json
    }
}

cd `dirname $0`

DEFAULT_IMG_DIR="docs/images/"
cp d2json.js ${DEFAULT_IMG_DIR}d2json.js
cd ${DEFAULT_IMG_DIR}
find . -name ".DS_Store" | xargs rm
node d2json > default_market_items.json
cd -
mv ${DEFAULT_IMG_DIR}default_market_items.json default_market_items.json
rm ${DEFAULT_IMG_DIR}d2json.js

remove_unnecessaries

mv default_market_items.json docs/default_market_items.json
