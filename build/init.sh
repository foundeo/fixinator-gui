#!/bin/sh

cd "$(dirname "$0")"
cd ../

npm install

cd resources/cfml/assets/

npm install

cd resources/cfml/

box install

cd ../../build/

./clean.sh

cd ../
#download box.jar

curl -o ./resources/box.jar https://s3.amazonaws.com/downloads.ortussolutions.com/ortussolutions/commandbox/5.1.1/box.jar

