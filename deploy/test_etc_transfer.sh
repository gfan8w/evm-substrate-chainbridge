#!/usr/bin/env sh

set -eu

set -a; source ./env.var; set +a;


echo "start transfer etc\n"

echo "query etc balance on WETC_CONTRACT:\n"
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 admin etc-balance \
    --address $SRC_WETC_CONTRACT


echo ""

ethc_amount=0.001
SRC_PPG_ADDRESS=0x292e141bc8cBe47c88765236A73DafC895A40127
echo "transfer to DST_ADDR on dst:"
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 erc20 depositETH \
    --amount $ethc_amount\
    --dest $DST_CHAIN_ID \
    --bridge $SRC_BRIDGE \
    --recipient $DST_ADDR \
    --resourceId $WETCRESOURCE_ID

echo ""

sleep 60

echo "query etc balance on WETC_CONTRACT:\n"
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 admin etc-balance \
    --address $SRC_WETC_CONTRACT

echo ""

echo "query etc balance of DST_ADDR on DST:\n"
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 erc20 balance \
--address $DST_ADDR \
--erc20Address $DST_WETCSHADOW_ERC20_CONTRACT

echo "query etc balance of PPG_ADDRESS on DST:\n"
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 erc20 balance \
--address $SRC_PPG_ADDRESS \
--erc20Address $DST_WETCSHADOW_ERC20_CONTRACT
 

echo ""

#注意在初始化合约的时候，设置的 mint 和 burn 权限

# 设置允许转账，允许handler 以owner的身份去转账, $DST_WETCSHADOW_ERC20_CONTRACT 合约中记录: $DST_ADDR -> $DST_20_HANDLER => amount
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 erc20 increase \
    --amount 1 \
    --erc20Address $DST_WETCSHADOW_ERC20_CONTRACT \
    --spender $DST_20_HANDLER

echo "transfer back etc to PPG_ADDRESS $SRC_PPG_ADDRESS\n"

echo "1) check balance on SRC for PPG_ADDRESS: $SRC_PPG_ADDRESS\n"
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 admin etc-balance \
    --address $SRC_PPG_ADDRESS

echo ""
echo "2) do transfer back\n"
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 erc20 deposit \
    --amount $ethc_amount \
    --dest $SRC_CHAIN_ID \
    --bridge $DST_BRIDGE \
    --recipient $SRC_PPG_ADDRESS \
    --resourceId $WETCRESOURCE_ID


echo ""

sleep 120

echo "3) query etc balance on WETC contract\n"
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 admin etc-balance \
    --address $SRC_WETC_CONTRACT


echo ""

sleep 60
echo "4) check again PPG_ADDRESS balance on SRC for address（fee deducted）: $SRC_PPG_ADDRESS\n"
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 admin etc-balance \
    --address $SRC_PPG_ADDRESS


















