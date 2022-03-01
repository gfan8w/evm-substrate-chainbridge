#!/usr/bin/env sh

set -eu

DIR="./bridge"
if [ -d "$DIR" ]; then
  echo "$DIR exists"
  #rm -rdf ./keys
else
  mkdir -p $DIR
fi


export PASSWORD=password
export SRC_CHAIN_ID=10
export DST_CHAIN_ID=0

 #https://ropsten.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161
#export SRC_GATEWAY=https://ropsten.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161
export SRC_GATEWAY=http://localhost:8545
#export DST_GATEWAY=http://localhost:8546
export DST_GATEWAY=http://123.58.217.221:9933


#export SRC_WSS=wss://ropsten.infura.io/ws/v3/5a4368b93922493ea7d9a9ee0f19a445
export SRC_WSS=ws://localhost:8545
#export DST_WSS=ws://localhost:8546
export DST_WSS=ws://123.58.217.221:9954
echo $SRC_WSS $DST_WSS


#确保这2个账户都有稍许的原生币在各自的链上
export SRC_ADDR="0x9ea356d25c658A648f408ABE2322F2f01F12A0F0"                           #lint
export SRC_PK="0x7f2dba38c010f6aad93c48bd77e72c1ea6720a40f45e46e96cc81e4e65a33866"

export DST_ADDR="0xFb07a28508F195bEaAc1ac621E2A3c2849Fd5143"                           #ccd
export DST_PK="0xece66015b367b49f6150608d0c72cc789424cd7442e2175a8c5ee9722380160b"

# ERC20MinterBurnerPauser.sol 合约，先独立通过metamask、remix部署好，并给 0x9ea356d25c658A648f408ABE2322F2f01F12A0F0 mint 一些ERC20的token
#export SRC_20_CONTRACT="0xab2bF0e2764F47bab36af9bEf58643848606834D"
#export RESOURCE_ID="0x000000000000000000000000000000637ebe4a02bbc34786d860b355f5a5ce00"

echo -e $SRC_CHAIN_ID '\n' $DST_CHAIN_ID '\n' $SRC_GATEWAY '\n' $DST_GATEWAY '\n' $SRC_ADDR '\n' $SRC_PK '\n' $DST_ADDR '\n' $DST_PK '\n'


echo -e "start to deploy SRC ERC20 token\n"

DEPLOY_SRC_ERC20() {
  cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 deploy \
--erc20 \
--erc20Decimals 18 \
--erc20Name SSARO \
--erc20Symbol SSARO
}

DEPLOYERC20_RESULT=$( DEPLOY_SRC_ERC20 | tee /dev/tty )

#trim: echo "  dd " | xargs echo -n  
#SRC_20_CONTRACT=$( echo $DEPLOYERC20_RESULT | awk '/ERC20.*deployed:/{sub(/.*ERC20.*deployed:/, ""); print}' | sed 's/ //g'  )  
SRC_20_CONTRACT=$( echo "$DEPLOYERC20_RESULT" | egrep -o '✓ ERC20.*$' | egrep -o "0x[a-fA-F0-9]{0,40}" | sed 's/ //g' )
export SRC_20_CONTRACT
echo "SRC_20_CONTRACT: " $SRC_20_CONTRACT "\n"
unset DEPLOYERC20_RESULT

if [ -z "$SRC_20_CONTRACT" ]; then
    echo "SRC_20_CONTRACT is unset or set to the empty string"
    exit 1
fi


echo -e "start to deploy SRC ERC721 token\n"

DEPLOY_SRC_ERC721() {
  cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 deploy \
--erc721
}

DEPLOYERC721_RESULT=$( DEPLOY_SRC_ERC721 | tee /dev/tty )

#trim: echo "  dd " | xargs echo -n  
#SRC_20_CONTRACT=$( echo $DEPLOYERC20_RESULT | awk '/ERC20.*deployed:/{sub(/.*ERC20.*deployed:/, ""); print}' | sed 's/ //g'  )  
SRC_721_CONTRACT=$( echo "$DEPLOYERC721_RESULT" | egrep -o '✓ ERC721.*$' | egrep -o "0x[a-fA-F0-9]{0,40}" | sed 's/ //g' )
export SRC_721_CONTRACT
echo "SRC_721_CONTRACT: " $SRC_721_CONTRACT "\n"
unset DEPLOYERC721_RESULT

if [ -z "$SRC_721_CONTRACT" ]; then
    echo "SRC_721_CONTRACT is unset or set to the empty string"
    exit 1
fi

echo ""

echo "deploy wetc\n"
DEPLOYWETC() {
# 部署 bridge 合约  和 Erc20 handler 合约
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 deploy \
    --wetc
}

DEPLOYWETC_RESULT=$( DEPLOYWETC | tee /dev/tty )
unset DEPLOYWETC

#trim: echo "  dd " | xargs echo -n
SRC_WETC_CONTRACT=$( echo "$DEPLOYWETC_RESULT" | egrep -o '✓ WETC contract.*$' | egrep -o "0x[a-fA-F0-9]{0,40}" | sed 's/ //g'  )   
export SRC_WETC_CONTRACT
echo "SRC_WETC_CONTRACT: " $SRC_WETC_CONTRACT

if [ -z "$SRC_WETC_CONTRACT" ]; then
    echo "SRC_WETC_CONTRACT is unset or set to the empty string"
    exit 1
fi

echo ""


echo -e "start to deploy DST ERC20 token \n"
DEPLOY_DST_ERC20() {
  cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 deploy \
--erc20 \
--erc20Decimals 18 \
--erc20Name wSARO \
--erc20Symbol wSARO
}

DEPLOYERC20_RESULT=$( DEPLOY_DST_ERC20 | tee /dev/tty )

#trim: echo "  dd " | xargs echo -n
DST_20_CONTRACT=$( echo "$DEPLOYERC20_RESULT" | egrep -o '✓ ERC20.*$' | egrep -o "0x[a-fA-F0-9]{0,40}" | sed 's/ //g'  )   
export DST_20_CONTRACT
echo -e "DST_20_CONTRACT: " $DST_20_CONTRACT "\n"
unset DEPLOYERC20_RESULT
if [ -z "$DST_20_CONTRACT" ]; then
    echo "DST_20_CONTRACT is unset or set to the empty string"
    exit 1
fi




echo -e "start to deploy DST ERC721 token \n"
DEPLOY_DST_ERC721() {
  cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 deploy \
--erc721
}

DEPLOYERC721_RESULT=$( DEPLOY_DST_ERC721 | tee /dev/tty )

#trim: echo "  dd " | xargs echo -n
DST_721_CONTRACT=$( echo "$DEPLOYERC721_RESULT" | egrep -o '✓ ERC721.*$' | egrep -o "0x[a-fA-F0-9]{0,40}" | sed 's/ //g'  )   
export DST_721_CONTRACT
echo -e "DST_721_CONTRACT: " $DST_721_CONTRACT "\n"
unset DEPLOYERC721_RESULT
if [ -z "$DST_721_CONTRACT" ]; then
    echo "DST_721_CONTRACT is unset or set to the empty string"
    exit 1
fi

echo ""


echo -e "start to deploy DST ERC20 wetc shadow token\n"

DEPLOY_DST_WETCSHADOW_ERC20() {
  cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 deploy \
--erc20 \
--erc20Decimals 18 \
--erc20Name WETCSHADOW \
--erc20Symbol WETCSHADOW
}

DEPLOY_DST_WETCSHADOW_ERC20_RESULT=$( DEPLOY_DST_WETCSHADOW_ERC20 | tee /dev/tty )

#trim: echo "  dd " | xargs echo -n  
#DST_WETCSHADOW_ERC20_CONTRACT=$( echo $DEPLOYERC20_RESULT | awk '/ERC20.*deployed:/{sub(/.*ERC20.*deployed:/, ""); print}' | sed 's/ //g'  )  
DST_WETCSHADOW_ERC20_CONTRACT=$( echo "$DEPLOY_DST_WETCSHADOW_ERC20_RESULT" | egrep -o '✓ ERC20.*$' | egrep -o "0x[a-fA-F0-9]{0,40}" | sed 's/ //g' )
export DST_WETCSHADOW_ERC20_CONTRACT
echo "DST_WETCSHADOW_ERC20_CONTRACT: " $DST_WETCSHADOW_ERC20_CONTRACT "\n"
unset DEPLOY_DST_WETCSHADOW_ERC20_RESULT

if [ -z "$DST_WETCSHADOW_ERC20_CONTRACT" ]; then
    echo "DST_WETCSHADOW_ERC20_CONTRACT is unset or set to the empty string"
    exit 1
fi


echo -e "deploy bridge\n"
DEPLOYBRIDBE() {
# 部署 bridge 合约  和 Erc20 handler 合约
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 deploy \
    --bridge --erc20Handler --erc721Handler \
    --relayers $SRC_ADDR \
    --WETCContract $SRC_WETC_CONTRACT \
    --relayerThreshold 1\
    --chainId $SRC_CHAIN_ID
}

DEPLOYBRIDBE_RESULT=$( DEPLOYBRIDBE | tee /dev/tty )
unset DEPLOYBRIDBE

#trim: echo "  dd " | xargs echo -n
SRC_BRIDGE=$( echo "$DEPLOYBRIDBE_RESULT" | egrep -o '✓ Bridge.*$' | egrep -o "0x[a-fA-F0-9]{0,40}" | sed 's/ //g'  )   
export SRC_BRIDGE
echo "SRC_BRIDGE: " $SRC_BRIDGE

if [ -z "$SRC_BRIDGE" ]; then
    echo "SRC_BRIDGE is unset or set to the empty string"
    exit 1
fi


#trim: echo "  dd " | xargs echo -n
SRC_20_HANDLER=$( echo "$DEPLOYBRIDBE_RESULT" | egrep -o '✓ ERC20Handler.*$' | egrep -o "0x[a-fA-F0-9]{0,40}" | sed 's/ //g'  )   
export SRC_20_HANDLER
echo "SRC_20_HANDLER: " $SRC_20_HANDLER
if [ -z "$SRC_20_HANDLER" ]; then
    echo "SRC_20_HANDLER is unset or set to the empty string"
    exit 1
fi


#trim: echo "  dd " | xargs echo -n
SRC_721_HANDLER=$( echo "$DEPLOYBRIDBE_RESULT" | egrep -o '✓ ERC721Handler.*$' | egrep -o "0x[a-fA-F0-9]{0,40}" | sed 's/ //g'  )   
export SRC_721_HANDLER
echo "SRC_721_HANDLER: " $SRC_721_HANDLER
unset DEPLOYBRIDBE_RESULT
if [ -z "$SRC_721_HANDLER" ]; then
    echo "SRC_721_HANDLER is unset or set to the empty string"
    exit 1
fi

echo ""



# 得到
# ✓ Bridge contract deployed: 0x71525F8fF3b0035818376643CDd8E6545d9309D4
# ✓ ERC20Handler contract deployed: 0x9435C413B4cd7db2194b594dF7ff950B030b2e91
#这2个合约的owner 是  0x9ea356d25c658A648f408ABE2322F2f01F12A0F0 ， 该地址也是 Relayers 的地址


#export SRC_BRIDGE="0x9af00e0B4A0E0c2B281E6c5BD3e3579c40A491fe"
#export SRC_20_HANDLER="0x5015c1B1828b3d6BAc9a33ec7C6F26a142359A1d"
#echo -e $SRC_BRIDGE '\n'  $SRC_20_HANDLER




GenerateERC20ResourceId() {
  cb-sol-cli admin generate-resource-id --address $SRC_20_HANDLER --chainId $SRC_CHAIN_ID
} 

GenerateERC20ResourceId_RESULT=$( GenerateERC20ResourceId | tee /dev/tty )

ERC20RESOURCE_ID=$( echo "$GenerateERC20ResourceId_RESULT" | egrep -o 'ResourceID.*$' | egrep -o "0x[a-fA-F0-9]{0,80}" | sed 's/ //g'  )   
export ERC20RESOURCE_ID
echo -e "ERC20RESOURCE_ID: " $ERC20RESOURCE_ID "\n"
unset GenerateERC20ResourceId_RESULT
if [ -z "$ERC20RESOURCE_ID" ]; then
    echo "ERC20RESOURCE_ID is unset or set to the empty string"
    exit 1
fi


GenerateERC721ResourceId() {
  cb-sol-cli admin generate-resource-id --address $SRC_721_HANDLER --chainId $SRC_CHAIN_ID
} 

GenerateERC721ResourceId_RESULT=$( GenerateERC721ResourceId | tee /dev/tty )

ERC721RESOURCE_ID=$( echo "$GenerateERC721ResourceId_RESULT" | egrep -o 'ResourceID.*$' | egrep -o "0x[a-fA-F0-9]{0,80}" | sed 's/ //g'  )   
export ERC721RESOURCE_ID
echo -e "ERC721RESOURCE_ID: " $ERC721RESOURCE_ID "\n"
unset GenerateERC721ResourceId_RESULT
if [ -z "$ERC721RESOURCE_ID" ]; then
    echo "ERC721RESOURCE_ID is unset or set to the empty string"
    exit 1
fi


GenerateWETCResourceId() {
  cb-sol-cli admin generate-resource-id --address $SRC_WETC_CONTRACT --chainId $SRC_CHAIN_ID
} 

GenerateWETCResourceId_RESULT=$( GenerateWETCResourceId | tee /dev/tty )

WETCRESOURCE_ID=$( echo "$GenerateWETCResourceId_RESULT" | egrep -o 'ResourceID.*$' | egrep -o "0x[a-fA-F0-9]{0,80}" | sed 's/ //g'  )   
export WETCRESOURCE_ID
echo -e "WETCRESOURCE_ID: " $WETCRESOURCE_ID "\n"
unset GenerateERC721ResourceId_RESULT
if [ -z "$WETCRESOURCE_ID" ]; then
    echo "WETCRESOURCE_ID is unset or set to the empty string"
    exit 1
fi



# 把ERC20合约 跟 bridge 及 handler 关联起来， RESOURCE_ID标识了 ERC20合约
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 bridge register-resource \
    --bridge $SRC_BRIDGE \
    --handler $SRC_20_HANDLER \
    --resourceId $ERC20RESOURCE_ID \
    --targetContract $SRC_20_CONTRACT

#把WETC合约跟 brigge及handler 关联起来，仅做src端就行
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 bridge register-resource \
    --bridge $SRC_BRIDGE \
    --handler $SRC_20_HANDLER \
    --resourceId $WETCRESOURCE_ID \
    --targetContract $SRC_WETC_CONTRACT


# 把ERC721合约 跟 bridge 及 handler 关联起来， RESOURCE_ID标识了 ERC20合约
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 bridge register-resource \
    --bridge $SRC_BRIDGE \
    --handler $SRC_721_HANDLER \
    --resourceId $ERC721RESOURCE_ID \
    --targetContract $SRC_721_CONTRACT


echo "\nquery resource on src handler\n"
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 bridge query-resource \
--handler $SRC_20_HANDLER \
--resourceId $ERC20RESOURCE_ID

cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 bridge query-resource \
--handler $SRC_20_HANDLER \
--resourceId $WETCRESOURCE_ID

cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 bridge query-resource \
--handler $SRC_721_HANDLER \
--resourceId $ERC721RESOURCE_ID


# 根据上面命令执行的tx结果，可以到   https://ropsten.etherscan.io/tx/0x8bf8b6bbc80ade4fb17465d84b2409e30a1d7e43c411e43abc85e6cb8682ebd6 去查询


#下面到  **目标链**  上去部署，我们这里的目标链是个本地链 http://localhost:8545， 本地链起来的时候，chainId已经指定为0

# 使用 $DST_ADDR 这个账号，部署localhost上的一个ERC20 合约： 0xaD68be91D7e60cDC75307d8c93A36bA9089Ee7F5
# 部署 ERC20MinterBurnerPauser 合约 0xaD68be91D7e60cDC75307d8c93A36bA9089Ee7F5 ,并给 部署的owner mint 一些token

# geth attach http://localhost:8545   #在docker 内部执行geth，给 $DST_ADDR 一点费用，主要是作为手续费

# eth.sendTransaction({from:"0xff93B45308FD417dF303D6515aB04D9e89a750Ca",to:"0xFb07a28508F195bEaAc1ac621E2A3c2849Fd5143", value: web3.toWei(10,"ether")})
# web3.fromWei(eth.getBalance("0xFb07a28508F195bEaAc1ac621E2A3c2849Fd5143"),"ether")

#部署一个 自己的ERC20合约
# export DST_20_CONTRACT="0xaD68be91D7e60cDC75307d8c93A36bA9089Ee7F5"
# echo "DST_20_CONTRACT" $DST_20_CONTRACT 

echo "\ndeploy bridge on DST\n"

# 以下命令没有用 --erc20，因为我们自己单独部署了erc20
DEPLOYBRIDBE() {
# 部署 bridge 合约  和 Erc20 handler 合约
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 deploy\
    --bridge --erc20Handler --erc721Handler \
    --relayers $DST_ADDR \
    --relayerThreshold 1 \
    --chainId $DST_CHAIN_ID
}

# 得到
# ✓ Bridge contract deployed: 0xa362e7f6FB76c941453B107e753eB4Dd88364676
# ✓ ERC20Handler contract deployed: 0x0a8B2aA4A70bE32d284F4679bc9A9D869B9a8533
# 这2个合约是 0xFb07a28508F195bEaAc1ac621E2A3c2849Fd5143 创建的，0xFb07a28508F195bEaAc1ac621E2A3c2849Fd5143 也是 Relayers 的地址

#export DST_BRIDGE="0x3640bf2f5C470c32F0Cd0Ab6c7E4B6f09EbAF0B1"
#export DST_20_HANDLER="0xa362e7f6FB76c941453B107e753eB4Dd88364676"
#echo -e $DST_BRIDGE "\n" $DST_20_HANDLER

DEPLOYBRIDBE_RESULT=$( DEPLOYBRIDBE | tee /dev/tty )
unset DEPLOYBRIDBE

#trim: echo "  dd " | xargs echo -n
DST_BRIDGE=$( echo "$DEPLOYBRIDBE_RESULT" | egrep -o '✓ Bridge.*$' | egrep -o "0x[a-fA-F0-9]{0,40}" | sed 's/ //g'  )   
export DST_BRIDGE
echo "DST_BRIDGE: " $DST_BRIDGE

if [ -z "$DST_BRIDGE" ]; then
    echo "DST_BRIDGE is unset or set to the empty string"
    exit 1
fi


#trim: echo "  dd " | xargs echo -n
DST_20_HANDLER=$( echo "$DEPLOYBRIDBE_RESULT" | egrep -o '✓ ERC20Handler.*$' | egrep -o "0x[a-fA-F0-9]{0,40}" | sed 's/ //g'  )   
export DST_20_HANDLER
echo "DST_20_HANDLER: " $DST_20_HANDLER
if [ -z "$DST_20_HANDLER" ]; then
    echo "SRC_20_HANDLER is unset or set to the empty string"
    exit 1
fi

DST_721_HANDLER=$( echo "$DEPLOYBRIDBE_RESULT" | egrep -o '✓ ERC721Handler.*$' | egrep -o "0x[a-fA-F0-9]{0,40}" | sed 's/ //g'  )   
export DST_721_HANDLER
echo "DST_721_HANDLER: " $DST_721_HANDLER
unset DEPLOYBRIDBE_RESULT
if [ -z "$DST_721_HANDLER" ]; then
    echo "DST_721_HANDLER is unset or set to the empty string"
    exit 1
fi


echo ""



# 在目标链上，把ERC20合约 跟 bridge 及 handler 关联起来， RESOURCE_ID标识了 ERC20合约
 
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 bridge register-resource \
    --bridge $DST_BRIDGE \
    --handler $DST_20_HANDLER \
    --resourceId $ERC20RESOURCE_ID \
    --targetContract $DST_20_CONTRACT

# wetc在目标端，关联Wetc的ERC20 shadow 的Contract，注意这里的contract用的是 DST_WETCSHADOW_ERC20_CONTRACT，
# 不是 DST_WETC_CONTRACT，也不是SRC_WETC_CONTRACT，实际并不存在 DST_WETC_CONTRACT
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 bridge register-resource \
    --bridge $DST_BRIDGE \
    --handler $DST_20_HANDLER \
    --resourceId $WETCRESOURCE_ID \
    --targetContract $DST_WETCSHADOW_ERC20_CONTRACT

cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 bridge register-resource \
    --bridge $DST_BRIDGE \
    --handler $DST_721_HANDLER \
    --resourceId $ERC721RESOURCE_ID \
    --targetContract $DST_721_CONTRACT

echo ""


echo "\nquery resource on dst handler\n"
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 bridge query-resource \
--handler $DST_20_HANDLER \
--resourceId $ERC721RESOURCE_ID

cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 bridge query-resource \
--handler $DST_20_HANDLER \
--resourceId $WETCRESOURCE_ID

cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 bridge query-resource \
--handler $DST_721_HANDLER \
--resourceId $ERC721RESOURCE_ID

echo ""

# 设置允许 burn 的权限
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 bridge set-burn \
    --bridge $DST_BRIDGE \
    --handler $DST_20_HANDLER \
    --tokenContract $DST_20_CONTRACT

echo ""

# 设置允许 mint 的权限
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 erc20 add-minter \
    --minter $DST_20_HANDLER \
    --erc20Address $DST_20_CONTRACT

echo ""


# 设置允许handler在DST_WETCSHADOW_ERC20_CONTRACT 做 burn 的权限
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 bridge set-burn \
    --bridge $DST_BRIDGE \
    --handler $DST_20_HANDLER \
    --tokenContract $DST_WETCSHADOW_ERC20_CONTRACT

echo ""

# 设置允许handler作为mint身份在DST_WETCSHADOW_ERC20_CONTRACT上 mint 的权限
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 erc20 add-minter \
    --minter $DST_20_HANDLER \
    --erc20Address $DST_WETCSHADOW_ERC20_CONTRACT

echo ""



# 设置手续费，双向都设置, ERC20 是2个为手续费，这里仅设置单向，不要设置 bridge上的 _fee 和 _specialFee，这里的跟resource 关联的fee是在handler上的。
# 转入都不收费，转出相当于提现，收费
echo "set erc20 fee to 2 on DST\n"
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 bridge set-fee \
--bridge $DST_BRIDGE \
--resourceId $ERC20RESOURCE_ID \
--fee 2 \
--decimal 18

# echo ""

# echo "set erc20 fee to 2 on SRC\n"
# cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 bridge set-fee \
# --bridge $SRC_BRIDGE \
# --resourceId $ERC20RESOURCE_ID \
# --fee 2 \
# --decimal 18


 echo "set etc fee to 0.0002 on DST\n"
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 bridge set-fee \
--bridge $DST_BRIDGE \
--resourceId $WETCRESOURCE_ID \
--fee 2 \
--decimal 14

echo ""

# 设置手续费，单向都设置, 原生币 etc 是0.0002个为手续费
# echo "set etc fee to 0.0002 on SRC\n"
# cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 bridge set-fee \
# --bridge $SRC_BRIDGE \
# --resourceId $WETCRESOURCE_ID \
# --fee 2 \
# --decimal 14






echo "{
  \"chains\": [
    {
      \"name\": \"Ropsten\",
      \"type\": \"ethereum\",
      \"id\": \"$SRC_CHAIN_ID\",
      \"endpoint\": \"$SRC_WSS\",
      \"from\": \"$SRC_ADDR\",
      \"opts\": {
        \"bridge\": \"$SRC_BRIDGE\",
        \"erc20Handler\": \"$SRC_20_HANDLER\",
        \"erc721Handler\": \"$SRC_721_HANDLER\",
        \"genericHandler\": \"$SRC_20_HANDLER\",
        \"gasLimit\": \"1000000\",
        \"maxGasPrice\": \"10000000000\"
      }
    },
    {
      \"name\": \"Local\",
      \"type\": \"ethereum\",
      \"id\": \"$DST_CHAIN_ID\",
      \"endpoint\": \"$DST_WSS\",
      \"from\": \"$DST_ADDR\",
      \"opts\": {
        \"bridge\": \"$DST_BRIDGE\",
        \"erc20Handler\": \"$DST_20_HANDLER\",
        \"erc721Handler\": \"$DST_721_HANDLER\",
        \"genericHandler\": \"$DST_20_HANDLER\",
        \"gasLimit\": \"1000000\",
        \"maxGasPrice\": \"10000000000\"
      }
    }
  ]
}" > $DIR/ropsten-local-config.json


# {
#   "chains": [
#     {
#       "name": "Ropsten",
#       "type": "ethereum",
#       "id": "10",
#       "endpoint": "https://ropsten.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
#       "from": "0x9ea356d25c658A648f408ABE2322F2f01F12A0F0",
#       "opts": {
#         "bridge": "0x71525F8fF3b0035818376643CDd8E6545d9309D4",
#         "erc20Handler": "0x9435C413B4cd7db2194b594dF7ff950B030b2e91",
#         "genericHandler": "0x9435C413B4cd7db2194b594dF7ff950B030b2e91",
#         "gasLimit": "1000000",
#         "maxGasPrice": "10000000000"
#       }
#     },
#     {
#       "name": "Local",
#       "type": "ethereum",
#       "id": "0",
#       "endpoint": "http://localhost:8545",
#       "from": "0xFb07a28508F195bEaAc1ac621E2A3c2849Fd5143",
#       "opts": {
#         "bridge": "0xaD68be91D7e60cDC75307d8c93A36bA9089Ee7F5",
#         "erc20Handler": "0x3640bf2f5C470c32F0Cd0Ab6c7E4B6f09EbAF0B1",
#         "genericHandler": "0x3640bf2f5C470c32F0Cd0Ab6c7E4B6f09EbAF0B1",
#         "gasLimit": "1000000",
#         "maxGasPrice": "10000000000"
#       }
#     }
#   ]
# }





# 生成key：
rm -rdf ./keys

$DIR/chainbridge accounts import --privateKey $SRC_PK --password $PASSWORD
$DIR/chainbridge accounts import --privateKey $DST_PK --password $PASSWORD

rm -rdf $DIR/keys && cp -R ./keys $DIR/

echo "key imported to $DIR/keys"
echo ""

# 设置环境变量：
export KEYSTORE_PASSWORD=$PASSWORD
echo KEYSTORE_PASSWORD $KEYSTORE_PASSWORD

# 在另外一个shell中运行 bridge  --verbosity trace --blockstore ./
echo "start run bridge..."
KEYSTORE_PASSWORD=$PASSWORD nohup $DIR/chainbridge --config $DIR/ropsten-local-config.json --verbosity trace --blockstore ./blockstore --latest > chainbridgelog.txt 2>&1 &
echo "chainbridge pid: $!"
sleep 20
tail -100 chainbridgelog.txt
echo ""
sleep 10



#输出变量，在外部 set -a; source ./env.var; set +a;
echo "PASSWORD=$PASSWORD
KEYSTORE_PASSWORD=$PASSWORD
SRC_CHAIN_ID=$SRC_CHAIN_ID
DST_CHAIN_ID=$DST_CHAIN_ID
SRC_GATEWAY=$SRC_GATEWAY
DST_GATEWAY=$DST_GATEWAY
SRC_WSS=$SRC_WSS
DST_WSS=$DST_WSS
DIR=$DIR
DST_ADDR=$DST_ADDR
SRC_ADDR=$SRC_ADDR
SRC_PK=$SRC_PK
DST_PK=$DST_PK
SRC_20_CONTRACT=$SRC_20_CONTRACT
DST_20_CONTRACT=$DST_20_CONTRACT
DST_WETCSHADOW_ERC20_CONTRACT=$DST_WETCSHADOW_ERC20_CONTRACT
SRC_721_CONTRACT=$SRC_721_CONTRACT
DST_721_CONTRACT=$DST_721_CONTRACT
ERC20RESOURCE_ID=$ERC20RESOURCE_ID
ERC721RESOURCE_ID=$ERC721RESOURCE_ID
SRC_WETC_CONTRACT=$SRC_WETC_CONTRACT
WETCRESOURCE_ID=$WETCRESOURCE_ID
SRC_BRIDGE=$SRC_BRIDGE
SRC_20_HANDLER=$SRC_20_HANDLER
SRC_721_HANDLER=$SRC_721_HANDLER
DST_BRIDGE=$DST_BRIDGE
DST_20_HANDLER=$DST_20_HANDLER
DST_721_HANDLER=$DST_721_HANDLER" >env.var








