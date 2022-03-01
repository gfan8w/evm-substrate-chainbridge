#!/usr/bin/env sh
# Copyright 2020 ChainSafe Systems
# SPDX-License-Identifier: LGPL-3.0-only

# Exit on failure
set -ex

[[ -d /root/.ethereum/ ]] && ls /root/.ethereum/

rm -rf /root/.ethereum/

geth init /root/genesis.json

rm -rf /root/.ethereum/keystore
cp -r /root/keystore /root/.ethereum/

exec geth \
    --networkid 2000 \
    --nodiscover \
    --unlock "0xff93B45308FD417dF303D6515aB04D9e89a750Ca","0x8e0a907331554AF72563Bd8D43051C2E64Be5d35","0x24962717f8fA5BA3b931bACaF9ac03924EB475a0","0x148FfB2074A9e59eD58142822b3eB3fcBffb0cd7","0x4CEEf6139f00F9F4535Ad19640Ff7A0137708485","0xfb07a28508f195beaac1ac621e2a3c2849fd5143" \
    --password /root/password.txt \
    --ws \
    --ws.port 8545 \
    --ws.origins="*" \
    --ws.addr 0.0.0.0 \
    --http \
    --http.port 8545 \
    --http.corsdomain="*" \
    --http.addr 0.0.0.0 \
    --miner.gaslimit 8000000 \
    --allow-insecure-unlock \
    --mine