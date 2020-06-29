#!/bin/sh

cd "$(dirname "$0")"
cd ../

rm -rf ./resources/cfml/assets/node_modules/ace-builds/demo/
rm -rf ./resources/cfml/assets/node_modules/ace-builds/src/
rm -rf ./resources/cfml/assets/node_modules/ace-builds/src-min-noconflict/
rm -rf ./resources/cfml/assets/node_modules/ace-builds/src-noconflict/
rm -rf ./resources/cfml/assets/node_modules/ace-builds/.github/

rm -rf ./resources/cfml/assets/node_modules/ace-builds/src-min/snippets/

rm -f ./resources/cfml/assets/node_modules/ace-builds/src-min/worker-*
rm -f ./resources/cfml/assets/node_modules/ace-builds/src-min/mode-xquery.js
rm -f ./resources/cfml/assets/node_modules/ace-builds/src-min/mode-php_laravel_blade.js
rm -f ./resources/cfml/assets/node_modules/ace-builds/src-min/mode-php.js
rm -f ./resources/cfml/assets/node_modules/ace-builds/src-min/mode-jsoniq.js
rm -f ./resources/cfml/assets/node_modules/ace-builds/src-min/keybinding-vim.js
rm -f ./resources/cfml/assets/node_modules/ace-builds/src-min/mode-csound_document.js
rm -f ./resources/cfml/assets/node_modules/ace-builds/src-min/mode-html_ruby.js

rm -rf ./resources/cfml/assets/node_modules/ace-diff/src/
rm -rf ./resources/cfml/assets/node_modules/ace-diff/test/

rm -rf ./resources/cfml/assets/node_modules/bootstrap-material-design/js/
rm -rf ./resources/cfml/assets/node_modules/bootstrap-material-design/scss/

rm -rf ./resources/cfml/assets/node_modules/jquery/src/
rm -rf ./resources/cfml/assets/node_modules/jquery/external/
rm -rf ./resources/cfml/assets/node_modules/jquery/dist/jquery.slim.*
rm -rf ./resources/cfml/assets/node_modules/jquery/dist/jquery.js

rm -rf ./resources/cfml/assets/node_modules/popper.js/src/
rm -rf ./resources/cfml/assets/node_modules/popper.js/dist/esm/
#rm -rf ./resources/cfml/assets/node_modules/popper.js/dist/umd/

rm -rf ./resources/cfml/assets/node_modules/lodash

find ./resources/cfml/assets/node_modules/ -name "*.html" -type f -delete
find ./resources/cfml/assets/node_modules/ -name "*.ts" -type f -delete
find ./resources/cfml/assets/node_modules/ -name "*.less" -type f -delete
find ./resources/cfml/assets/node_modules/ -name "*.scss" -type f -delete

# chrome will load woff2
find ./resources/cfml/assets/node_modules/ -name "*.woff" -type f -delete


rm -rf ./resources/cfml/coldbox/system/cache/report/
rm -rf ./resources/cfml/coldbox/system/cache/config/samples/
rm -f ./resources/cfml/coldbox/system/cache/store/indexers/JDBCMetadataIndexer.cfc
rm -rf ./resources/cfml/coldbox/system/cache/store/sql/
rm -f ./resources/cfml/coldbox/system/cache/store/JDBCStore.cfc
rm -rf ./resources/cfml/coldbox/system/remote/
rm -rf ./resources/cfml/coldbox/system/testing/
rm -rf ./resources/cfml/coldbox/system/includes/


