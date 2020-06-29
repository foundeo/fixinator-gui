#!/bin/sh

cd "$(dirname "$0")"
cd ../

#install electron deps
npm install

npm audit

#install client JS deps
cd resources/cfml/assets/

npm install

npm audit

cd ../../../

pwd

#download box.jar

curl -o ./resources/box.jar https://s3.amazonaws.com/downloads.ortussolutions.com/ortussolutions/commandbox/5.1.1/box.jar

cd resources/cfml/

#box install cfml deps
java -jar ../box.jar install

#clean deps
cd ../../build

./clean.sh