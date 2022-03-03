#!/usr/bin/env bash

# Exit on failure
set -ex

echo "start run bridge" `date +"%Y-%m-%d %H:%M:%S.%z"`

#WORKDIR /app

set -a; source ./config/env.var; set +a;

chmod +x ./bridge

rm -rdf ./keys

./bridge accounts import --privateKey $SRC_PK --password $KEYSTORE_PASSWORD
./bridge accounts import --privateKey $DST_PK --password $KEYSTORE_PASSWORD

nohup ./bridge --config ./config/config.json --blockstore ./blockstore --latest > ./logs/chainbridgelog.txt 2>&1 &

tail -f ./logs/chainbridgelog.txt
