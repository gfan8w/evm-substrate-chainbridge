const ethers = require('ethers');
const constants = require('../constants');

const {Command} = require('commander');
const {setupParentArgs, getFunctionBytes, safeSetupParentArgs, safeTransactionAppoveExecute, splitCommaList, waitForTx, log, logSafe,expandDecimals} = require("./utils")

const EMPTY_SIG = "0x00000000"

const registerResourceCmd = new Command("register-resource")
    .description("Register a resource ID with a contract address for a handler")
    .option('--bridge <address>', 'Bridge contract address', constants.BRIDGE_ADDRESS)
    .option('--handler <address>', 'Handler address', constants.ERC20_HANDLER_ADDRESS)
    .option('--targetContract <address>', `Contract address to be registered`, constants.ERC20_ADDRESS)
    .option('--resourceId <address>', `Resource ID to be registered`, constants.ERC20_RESOURCEID)
    .action(async function (args) {
        await setupParentArgs(args, args.parent.parent)
        log(args,`Registering contract ${args.targetContract} with resource ID ${args.resourceId} on handler ${args.handler}`);
        const bridgeInstance = new ethers.Contract(args.bridge, constants.ContractABIs.Bridge.abi, args.wallet);
        log(args,`Registering contract ${args.targetContract} with resource ID ${args.resourceId} on handler ${args.handler}`);
        const tx = await bridgeInstance.adminSetResource(args.handler, args.resourceId, args.targetContract, { gasPrice: args.gasPrice, gasLimit: args.gasLimit});
        await waitForTx(args.provider, tx.hash)
    })

    const setFeeCmd = new Command("set-fee")
    .description("add resource fee for source handler")
    .option('--bridge <address>', 'Bridge contract address', constants.BRIDGE_ADDRESS)
    .option('--fee <value>', 'resource fee', constants.BRIDGE_ADDRESS)
    .option('--decimal <value>', "The number of decimal places for the erc20 token", 18)
    .option('--resourceId <address>', `Resource ID to be registered`, constants.ERC20_RESOURCEID)
    .action(async function (args) {
        await setupParentArgs(args, args.parent.parent)
        console.log(args.decimal)
        let amount=expandDecimals(args.fee, args.decimal*1);
        log(args,`Registering with resource ID ${args.resourceId} on fee ${amount}`);
        const bridgeInstance = new ethers.Contract(args.bridge, constants.ContractABIs.Bridge.abi, args.wallet);
        log(args,`Registering  with resource ID ${args.resourceId} on fee ${amount}`);
        const tx = await bridgeInstance.adminSetFee(args.resourceId, amount, { gasPrice: args.gasPrice, gasLimit: args.gasLimit});
        await waitForTx(args.provider, tx.hash)
    })

const safeRegisterResourceCmd = new Command("safe-register-resource")
    .description("Register a resource ID with a contract address for a handler")
    .option('--bridge <address>', 'Bridge contract address', constants.BRIDGE_ADDRESS)
    .option('--handler <address>', 'Handler address', constants.ERC20_HANDLER_ADDRESS)
    .option('--targetContract <address>', `Contract address to be registered`, constants.ERC20_ADDRESS)
    .option('--resourceId <address>', `Resource ID to be registered`, constants.ERC20_RESOURCEID)
    .requiredOption('--multiSig <value>', 'Address of Multi-sig which will acts bridge admin')
    .option('--approve', 'Approve transaction hash')
    .option('--execute', 'Execute transaction')
    .option('--approvers <value>', 'Approvers addresses', splitCommaList)
    .action(async function (args) {
        await safeSetupParentArgs(args, args.parent.parent)

        logSafe(args,`Registering contract ${args.targetContract} with resource ID ${args.resourceId} on handler ${args.handler}`);

        await safeTransactionAppoveExecute(args, 'adminSetResource', [args.handler, args.resourceId, args.targetContract])
    })

const registerGenericResourceCmd = new Command("register-generic-resource")
    .description("Register a resource ID with a generic handler")
    .option('--bridge <address>', 'Bridge contract address', constants.BRIDGE_ADDRESS)
    .option('--handler <address>', 'Handler contract address', constants.GENERIC_HANDLER_ADDRESS)
    .option('--targetContract <address>', `Contract address to be registered`, constants.CENTRIFUGE_ASSET_STORE_ADDRESS)
    .option('--resourceId <address>', `ResourceID to be registered`, constants.GENERIC_RESOURCEID)
    .option('--deposit <string>', "Deposit function signature", EMPTY_SIG)
    .option('--depositOffset <value>', "Deposit function offset", 0)
    .option('--execute <string>', "Execute proposal function signature", EMPTY_SIG)
    .option('--hash', "Treat signature inputs as function prototype strings, hash and take the first 4 bytes", false)
    .action(async function(args) {
        await setupParentArgs(args, args.parent.parent)

        const bridgeInstance = new ethers.Contract(args.bridge, constants.ContractABIs.Bridge.abi, args.wallet);

        if (args.hash) {
            args.deposit = getFunctionBytes(args.deposit)
            args.execute = getFunctionBytes(args.execute)
        }

        log(args,`Registering generic resource ID ${args.resourceId} with contract ${args.targetContract} on handler ${args.handler}`)
        const tx = await bridgeInstance.adminSetGenericResource(args.handler, args.resourceId, args.targetContract, args.deposit, args.depositOffset, args.execute, { gasPrice: args.gasPrice, gasLimit: args.gasLimit})
        await waitForTx(args.provider, tx.hash)
    })

const safeRegisterGenericResourceCmd = new Command("safe-register-generic-resource")
    .description("Register a resource ID with a generic handler")
    .option('--bridge <address>', 'Bridge contract address', constants.BRIDGE_ADDRESS)
    .option('--handler <address>', 'Handler contract address', constants.GENERIC_HANDLER_ADDRESS)
    .option('--targetContract <address>', `Contract address to be registered`, constants.CENTRIFUGE_ASSET_STORE_ADDRESS)
    .option('--resourceId <address>', `ResourceID to be registered`, constants.GENERIC_RESOURCEID)
    .option('--depositSig <string>', "Deposit function signature", EMPTY_SIG)
    .option('--depositOffset <value>', "Deposit function offset", 0)
    .option('--executeSig <string>', "Execute proposal function signature", EMPTY_SIG)
    .option('--hash', "Treat signature inputs as function prototype strings, hash and take the first 4 bytes", false)
    .requiredOption('--multiSig <value>', 'Address of Multi-sig which will acts bridge admin')
    .option('--approve', 'Approve transaction hash')
    .option('--execute', 'Execute transaction')
    .option('--approvers <value>', 'Approvers addresses', splitCommaList)
    .action(async function(args) {
        await safeSetupParentArgs(args, args.parent.parent)

        if (args.hash) {
            args.deposit = getFunctionBytes(args.deposit)
            args.execute = getFunctionBytes(args.execute)
        }

        logSafe(args,`Registering generic resource ID ${args.resourceId} with contract ${args.targetContract} on handler ${args.handler}`)

        await safeTransactionAppoveExecute(args, 'adminSetGenericResource', [args.handler, args.resourceId, args.targetContract, args.deposit, args.depositOffset, args.execute])
    })

const setBurnCmd = new Command("set-burn")
    .description("Set a token contract as burnable in a handler")
    .option('--bridge <address>', 'Bridge contract address', constants.BRIDGE_ADDRESS)
    .option('--handler <address>', 'ERC20 handler contract address', constants.ERC20_HANDLER_ADDRESS)
    .option('--tokenContract <address>', `Token contract to be registered`, constants.ERC20_ADDRESS)
    .action(async function (args) {
        await setupParentArgs(args, args.parent.parent)
        const bridgeInstance = new ethers.Contract(args.bridge, constants.ContractABIs.Bridge.abi, args.wallet);

        log(args,`Setting contract ${args.tokenContract} as burnable on handler ${args.handler}`);
        const tx = await bridgeInstance.adminSetBurnable(args.handler, args.tokenContract, { gasPrice: args.gasPrice, gasLimit: args.gasLimit});
        await waitForTx(args.provider, tx.hash)
    })

const safeSetBurnCmd = new Command("sefe-set-burn")
    .description("Set a token contract as burnable in a handler")
    .option('--bridge <address>', 'Bridge contract address', constants.BRIDGE_ADDRESS)
    .option('--handler <address>', 'ERC20 handler contract address', constants.ERC20_HANDLER_ADDRESS)
    .option('--tokenContract <address>', `Token contract to be registered`, constants.ERC20_ADDRESS)
    .requiredOption('--multiSig <value>', 'Address of Multi-sig which will acts bridge admin')
    .option('--approve', 'Approve transaction hash')
    .option('--execute', 'Execute transaction')
    .option('--approvers <value>', 'Approvers addresses', splitCommaList)
    .action(async function (args) {
        await safeSetupParentArgs(args, args.parent.parent)

        logSafe(args,`Setting contract ${args.tokenContract} as burnable on handler ${args.handler}`);

        await safeTransactionAppoveExecute(args, 'adminSetBurnable', [args.handler, args.tokenContract])
    })

const cancelProposalCmd = new Command("cancel-proposal")
    .description("Cancel a proposal that has passed the expiry threshold")
    .option('--bridge <address>', 'Bridge contract address', constants.BRIDGE_ADDRESS)
    .option('--chainId <id>', 'Chain ID of proposal to cancel', 0)
    .option('--depositNonce <value>', 'Deposit nonce of proposal to cancel', 0)
    .action(async function (args) {
        await setupParentArgs(args, args.parent.parent)
        const bridgeInstance = new ethers.Contract(args.bridge, constants.ContractABIs.Bridge.abi, args.wallet);

        log(args, `Setting proposal with chain ID ${args.chainId} and deposit nonce ${args.depositNonce} status to 'Cancelled`);
        const tx = await bridgeInstance.adminCancelProposal(args.chainId, args.depositNonce);
        await waitForTx(args.provider, tx.hash)
    })

const safeCancelProposalCmd = new Command("safe-cancel-proposal")
    .description("Cancel a proposal that has passed the expiry threshold")
    .option('--bridge <address>', 'Bridge contract address', constants.BRIDGE_ADDRESS)
    .option('--chainId <id>', 'Chain ID of proposal to cancel', 0)
    .option('--depositNonce <value>', 'Deposit nonce of proposal to cancel', 0)
    .requiredOption('--multiSig <value>', 'Address of Multi-sig which will acts bridge admin')
    .option('--approve', 'Approve transaction hash')
    .option('--execute', 'Execute transaction')
    .option('--approvers <value>', 'Approvers addresses', splitCommaList)
    .action(async function (args) {
        await safeSetupParentArgs(args, args.parent.parent)

        logSafe(args, `Setting proposal with chain ID ${args.chainId} and deposit nonce ${args.depositNonce} status to 'Cancelled`);

        await safeTransactionAppoveExecute(args, 'adminCancelProposal', [args.chainId, args.depositNonce])
    })

const queryProposalCmd = new Command("query-proposal")
    .description("Queries a proposal")
    .option('--bridge <address>', 'Bridge contract address', constants.BRIDGE_ADDRESS)
    .option('--chainId <id>', 'Source chain ID of proposal', 0)
    .option('--depositNonce <value>', 'Deposit nonce of proposal', 0)
    .option('--dataHash <value>', 'Hash of proposal metadata', constants.ERC20_PROPOSAL_HASH)
    .action(async function (args) {
        await setupParentArgs(args, args.parent.parent)
        const bridgeInstance = new ethers.Contract(args.bridge, constants.ContractABIs.Bridge.abi, args.wallet);

        const prop = await bridgeInstance.getProposal(args.chainId, args.depositNonce, args.dataHash)

        console.log(prop)
    })



const queryAdmin = new Command("query-admin")
.description("Queries a proposal")
.option('--bridge <address>', 'Bridge contract address', constants.BRIDGE_ADDRESS)
.action(async function (args) {
    await setupParentArgs(args, args.parent.parent)
    const bridgeInstance = new ethers.Contract(args.bridge, constants.ContractABIs.Bridge.abi, args.wallet);

    const prop = await bridgeInstance.getAdmin()

    console.log(prop)
})

const queryResourceId = new Command("query-resource")
    .description("Query the contract address associated with a resource ID")
    .option('--handler <address>', 'Handler contract address', constants.ERC20_HANDLER_ADDRESS)
    .option('--resourceId <address>', `ResourceID to query`, constants.ERC20_RESOURCEID)
    .action(async function(args) {
        await setupParentArgs(args, args.parent.parent)

        const handlerInstance = new ethers.Contract(args.handler, constants.ContractABIs.HandlerHelpers.abi, args.wallet)
        const address = await handlerInstance._resourceIDToTokenContractAddress(args.resourceId)
        log(args, `Resource ID ${args.resourceId} is mapped to contract ${address}`)
    })

    const queryResourceFee = new Command("query-resource--fee")
    .description("Query the contract address associated with a resource ID")
    .option('--handler <address>', 'Handler contract address', constants.ERC20_HANDLER_ADDRESS)
    .option('--resourceId <address>', `ResourceID to query`, constants.ERC20_RESOURCEID)
    .action(async function(args) {
        await setupParentArgs(args, args.parent.parent)

        const handlerInstance = new ethers.Contract(args.handler, constants.ContractABIs.Erc20Handler.abi, args.wallet)
        const fee = await handlerInstance.getFee(args.resourceId)
        log(args, `Resource ID ${args.resourceId} is mapped to contract ${fee}`)
    })


const queryFeeCmd = new Command("query-fee")
    .description("Queries fee of bridge to destination chain")
    .option('--bridge <address>', 'Bridge contract address', constants.BRIDGE_ADDRESS)
    .option('--destinationChainID <value>', 'Deposit nonce of proposal', 1)
    .action(async function (args) {
        await setupParentArgs(args, args.parent.parent)
        const bridgeInstance = new ethers.Contract(args.bridge, constants.ContractABIs.Bridge.abi, args.wallet);

        const fee = await bridgeInstance.getFee(args.destinationChainID);

        console.log("fee: " + fee.toString() + " (wei), for destination chainID: " + args.destinationChainID.toString());
    })

const bridgeCmd = new Command("bridge")

bridgeCmd.addCommand(registerResourceCmd)
bridgeCmd.addCommand(setFeeCmd)
bridgeCmd.addCommand(safeRegisterResourceCmd)
bridgeCmd.addCommand(registerGenericResourceCmd)
bridgeCmd.addCommand(safeRegisterGenericResourceCmd)
bridgeCmd.addCommand(setBurnCmd)
bridgeCmd.addCommand(safeSetBurnCmd)
bridgeCmd.addCommand(cancelProposalCmd)
bridgeCmd.addCommand(safeCancelProposalCmd)
bridgeCmd.addCommand(queryProposalCmd)
bridgeCmd.addCommand(queryResourceId)
bridgeCmd.addCommand(queryFeeCmd)
bridgeCmd.addCommand(queryResourceFee)
bridgeCmd.addCommand(queryAdmin)



module.exports = bridgeCmd
