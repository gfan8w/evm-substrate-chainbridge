#!/usr/bin/env sh

# Contract Addresses
# ================================================================
# Bridge:             0x62877dDCd49aD22f5eDfc6ac108e9a4b5D2bD88B
# ----------------------------------------------------------------
# Erc20 Handler:      0x3167776db165D8eA0f51790CA2bbf44Db5105ADF
# ----------------------------------------------------------------
# Erc721 Handler:     0x3f709398808af36ADBA86ACC617FeB7F5B7B193E
# ----------------------------------------------------------------
# Generic Handler:    0x2B6Ab4b880A45a07d83Cf4d664Df4Ab85705Bc07
# ----------------------------------------------------------------
# Erc20:              0x21605f71845f372A9ed84253d2D024B7B10999f4
# ----------------------------------------------------------------
# Erc721:             0xd7E33e1bbf65dC001A0Eb1552613106CD7e40C31


set -exu

cb-sol-cli deploy --all --relayerThreshold 1

cb-sol-cli bridge register-resource --resourceId "0x000000000000000000000000000000c76ebe4a02bbc34786d860b355f5a5ce00" --targetContract "0x21605f71845f372A9ed84253d2D024B7B10999f4"

cb-sol-cli bridge register-resource --resourceId "0x000000000000000000000000000000e389d61c11e5fe32ec1735b3cd38c69501" --targetContract "0xd7E33e1bbf65dC001A0Eb1552613106CD7e40C31" --handler "0x3f709398808af36ADBA86ACC617FeB7F5B7B193E"


cb-sol-cli bridge register-generic-resource --resourceId "0x000000000000000000000000000000f44be64d2de895454c3467021928e55e01" --targetContract "0xc279648CE5cAa25B9bA753dAb0Dfef44A069BaF4" --handler "0x2B6Ab4b880A45a07d83Cf4d664Df4Ab85705Bc07" --hash --deposit "" --execute "store(bytes32)"


cb-sol-cli bridge set-burn --tokenContract "0x21605f71845f372A9ed84253d2D024B7B10999f4"


cb-sol-cli erc20 add-minter --minter "0x3167776db165D8eA0f51790CA2bbf44Db5105ADF"


cb-sol-cli bridge set-burn --tokenContract "0xd7E33e1bbf65dC001A0Eb1552613106CD7e40C31" --handler "0x3f709398808af36ADBA86ACC617FeB7F5B7B193E"


cb-sol-cli erc721 add-minter --minter "0x3f709398808af36ADBA86ACC617FeB7F5B7B193E"


chainbridge --config config.json --testkey alice --verbosity trace --latest


从eth 转到 substrate：

cb-sol-cli erc20 mint --amount 1000

cb-sol-cli erc20 approve --amount 1000 --recipient "0x3167776db165D8eA0f51790CA2bbf44Db5105ADF"

cb-sol-cli erc20 deposit --amount 1 --dest 1 --recipient "0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d" --resourceId "0x000000000000000000000000000000c76ebe4a02bbc34786d860b355f5a5ce00"

INFO[02-14|16:38:52] Handling fungible deposit event          chain=eth dest=1 nonce=1
TRCE[02-14|16:38:52] Routing message                          system=router src=0 dest=1 nonce=1 rId=000000000000000000000000000000c76ebe4a02bbc34786d860b355f5a5ce00
DBUG[02-14|16:38:52] Querying block for deposit events        chain=eth block=8316
INFO[02-14|16:38:52] Acknowledging proposal on chain          chain=sub nonce=1 source=0 resource=000000000000000000000000000000c76ebe4a02bbc34786d860b355f5a5ce00 method=Example.transfer
DBUG[02-14|16:38:52] Submitting substrate call...             chain=sub method=ChainBridge.acknowledge_proposal sender=5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY
DBUG[02-14|16:38:52] Block not ready, will retry              chain=eth target=8317 latest=8326
TRCE[02-14|16:38:52] Extrinsic submission succeeded           chain=sub
TRCE[02-14|16:38:54] Extrinsic included in block              chain=sub block=0xeaefe00d8a126c3ff34bd2da1d5bd1fb65f6a5c052aec0c59a6d59055cedaf77
TRCE[02-14|16:38:54] Block not yet finalized                  chain=sub target=1386 latest=1385

































