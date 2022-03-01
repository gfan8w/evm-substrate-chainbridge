#!/usr/bin/env sh

set -eu

set -a; source ./env.var; set +a;

#确保 这2个账户有少许原生币用户支付手续费
SRC_3RD_ADDR=0x6Da573EEc80f63c98b88cED15D32CA270787FB5a # geth-1990
DST_3RD_ADDR=0x52a51DC2AaD7f425679356269A47B6B4BAb672fc # geth-2000

SRC_3RD_PK=0x72e10fc29436e93f1c974564c6cbec3f2873ded6d9261af06c87be85dad320e4
DST_3RD_PK=0xace81b78ecd7bd992b0d586d472ec697997b534bfccd274594054d1e3e03ec6f


echo "mint:\n"

echo "check balance of minter($SRC_ADDR):\n"
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 erc20 balance \
--address $SRC_ADDR \
--erc20Address $SRC_20_CONTRACT

#给某个账户mint erc20的币
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 erc20 transfer \
--amount 1000 \
--address $SRC_3RD_ADDR \
--erc20Address $SRC_20_CONTRACT



echo ""

#查余额
echo "check balance of SRC_3RD_ADDR($SRC_3RD_ADDR):\n"
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_3RD_PK --gasPrice 10000000000 erc20 balance \
--address $SRC_3RD_ADDR \
--erc20Address $SRC_20_CONTRACT

echo ""

# 设置允许转账，允许handler 以我们的身份去转账, $SRC_TOKEN合约中记录: $SRC_ADDR -> $SRC_20_HANDLER => amount
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_3RD_PK --gasPrice 10000000000 erc20 increase \
    --amount 5000 \
    --erc20Address $SRC_20_CONTRACT \
    --spender $SRC_20_HANDLER

echo ""

echo "start a transfer to DST_3RD_ADDR: $DST_3RD_ADDR \n"

echo "before transfer, check SRC_20_HANDLER balance in $SRC_20_HANDLER \n"
# 查handler的余额
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_3RD_PK --gasPrice 10000000000 erc20 balance \
--address $SRC_20_HANDLER \
--erc20Address $SRC_20_CONTRACT


echo `date +"%Y-%m-%d %H:%M:%S.%z"` ":" "transfer\n"

# 转账, 
# 一般情况下，转账到某个用户地址，是在合约$SRC_20_CONTRACT 上由 $SRC_ADDR 向某个用户地址转账，
# 这里是在合约$SRC_20_CONTRACT 上由 $SRC_ADDR 向 $SRC_20_HANDLER 地址转账， 
# eth 级别看， 是 $SRC_ADDR 在操作 $SRC_BRIDGE 合约的 Deposit 方法
# 从ERC20的$SRC_TOKEN合约端看， 是 $SRC_ADD 向 SRC_20_HANDLER 转账

#源这边是 $SRC_ADD 向 $SRC_20_HANDLER 转账，锁定 amount 数量的代币， 该笔交易发生在 $SRC_20_CONTRACT 合约上
# 调用的是 transferFrom 方法，from 是 $SRC_ADD， 目标是 $SRC_20_HANDLER
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_3RD_PK --gasPrice 10000000000 erc20 deposit \
    --amount 100 \
    --dest $DST_CHAIN_ID \
    --bridge $SRC_BRIDGE \
    --recipient $DST_3RD_ADDR \
    --resourceId $ERC20RESOURCE_ID

echo ""


# 查余额
echo "after transfer, check balance in SRC_20_HANDLER $SRC_20_HANDLER \n"
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_3RD_PK --gasPrice 10000000000 erc20 balance \
--address $SRC_20_HANDLER \
--erc20Address $SRC_20_CONTRACT

echo "after transfer, check balance in SRC_3RD_ADDR $SRC_3RD_ADDR \n"
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_3RD_PK --gasPrice 10000000000 erc20 balance \
--address $SRC_3RD_ADDR \
--erc20Address $SRC_20_CONTRACT

echo ""
sleep 40
echo "after transfer, check target dest balance $DST_3RD_ADDR \n"
cb-sol-cli --url $DST_GATEWAY --privateKey $SRC_3RD_PK --gasPrice 10000000000 erc20 balance \
--address $DST_3RD_ADDR \
--erc20Address $DST_20_CONTRACT  

echo ""

echo "TRANSFER BACK\n"
# 转回来
# 首先要允许 handler 操作币主人的币
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_3RD_PK --gasPrice 10000000000 erc20 increase \
    --amount 600 \
    --erc20Address $DST_20_CONTRACT \
    --spender $DST_20_HANDLER

echo ""    

# 发起转账操作。 $DST_20_HANDLER 不会保存，因为前面有设置burn，它被销毁了。

echo "" 

echo `date +"%Y-%m-%d %H:%M:%S.%z"` ":" "transfer\n"

cb-sol-cli --url $DST_GATEWAY --privateKey $DST_3RD_PK --gasPrice 10000000000 erc20 deposit \
    --amount 10 \
    --dest $SRC_CHAIN_ID \
    --bridge $DST_BRIDGE \
    --recipient $SRC_3RD_ADDR \
    --resourceId $ERC20RESOURCE_ID

sleep 40

echo ""

echo "check balance on handler on SRC:"
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_3RD_PK --gasPrice 10000000000 erc20 balance \
--address $SRC_20_HANDLER \
--erc20Address $SRC_20_CONTRACT

echo ""
echo "check balance on SRC_ADDR on SRC (fee deducted):"

cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_3RD_PK --gasPrice 10000000000 erc20 balance \
--address $SRC_3RD_ADDR \
--erc20Address $SRC_20_CONTRACT

# bridge 合约部署的时候，
# 1）初始化 会传入 chain-id，relayer，fees，过期时间。relayer就是一个用户账号
# 2）绑定资源 set-resource ：
#    这个时候已经有handler合约部署好了。
#    2.1）传入 resource_id, handler的合约地址，普通ERC20合约地址(tokenContract)
#    2.2）resource_id 对应 handler， resource_id 就是一个主键，标识对应的handler是谁，该resource 由谁handle处理
#    2.3）获取handler合约的实例，设置handler合约上的 resource_id 与 普通ERC20合约tokenContract的地址的关系，
#         它会维护一个双向的关系，即 resource_id -> tokenContract 和 tokenContract -> resource_id
#         它还设置一个白名单， tokenContract 在白名单内
#    2.4）resource_id 对应2个合约，在bridge上是 res_id -> handler, 在handler合约上是 res_id -> tokenContract
# bridge 合约的deposit 方法转账：
# 参数： 1）调用者
#       2）目标链 chain-id
#       3）data： 金额+接收地址长度+接收地址，每个32字节对齐
#       4）resource_id: 资源标识符




















