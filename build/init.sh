#!/bin/sh

cd "$(dirname "$0")"
cd ../

npm install

npm audit

cd resources/cfml/assets/

npm install

npm audit

cd ../../../build/

./clean.sh

cd ../

#download box.jar

curl -o ./resources/box.jar https://s3.amazonaws.com/downloads.ortussolutions.com/ortussolutions/commandbox/5.1.1/box.jar

cd resources/cfml/

#box install
java -jar ../box.jar install

