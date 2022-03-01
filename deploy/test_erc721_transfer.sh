#!/usr/bin/env sh

set -eu

set -a; source ./env.var; set +a;



#源端允许 handler铸造
echo "add-minter set-burn on SRC 721 token"
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 1000000000 erc721 add-minter \
--minter $SRC_721_HANDLER \
--erc721Address $SRC_721_CONTRACT

#在SRC端，转移后销毁
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 bridge set-burn \
--bridge $SRC_BRIDGE \
--handler $SRC_721_HANDLER \
--tokenContract $SRC_721_CONTRACT

# ERC721 token 新建
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 erc721 mint \
--erc721Address $SRC_721_CONTRACT \
--id 0x1

echo ""
# 查询owner
echo "query owner of ERC721_token:"
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 erc721 owner \
--erc721Address $SRC_721_CONTRACT \
--id 0x1

echo ""
#允许转移
echo "approve of ERC721_token:"
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 erc721 approve \
--erc721Address $SRC_721_CONTRACT \
--recipient $SRC_721_HANDLER \
--id 0x1


echo ""

#目标端可新建
echo "let DST_721_Handler can mint on DST\n"
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 1000000000 erc721 add-minter \
--minter $DST_721_HANDLER \
--erc721Address $DST_721_CONTRACT

#目标端转移后销毁
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 1000000000 bridge set-burn \
--bridge $DST_BRIDGE \
--handler $DST_721_HANDLER \
--tokenContract $DST_721_CONTRACT



echo ""

echo "deposit of ERC721_token to DST:" `date +"%Y-%m-%d %H:%M:%S.%z"`

cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 erc721 deposit \
--dest $DST_CHAIN_ID \
--bridge $SRC_BRIDGE \
--recipient $DST_ADDR \
--resourceId $ERC721RESOURCE_ID \
--id 0x1


# echo "query owner of ERC721_token on SRC again:"
# cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 erc721 owner \
# --erc721Address $SRC_721_CONTRACT \
# --id 0x1

echo ""
sleep 120
echo "query owner of ERC721_token on DST:"
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 erc721 owner \
--erc721Address $DST_721_CONTRACT \
--id 0x1

echo ""


# 从DST转回来到SRC，先要设置允许
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 erc721 approve \
--erc721Address $DST_721_CONTRACT \
--recipient $DST_721_HANDLER \
--id 0x1

cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 erc721 deposit \
--dest $SRC_CHAIN_ID \
--bridge $DST_BRIDGE \
--recipient 0xA7e6d6bBfe7E938561863316239Fa94aFbda7B41 \
--resourceId $ERC721RESOURCE_ID \
--id 0x1

sleep 120
echo "query owner of ERC721_token on SRC after transfer back:"
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 erc721 owner \
--erc721Address $SRC_721_CONTRACT \
--id 0x1


echo ""


















