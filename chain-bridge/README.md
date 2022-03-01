# vmbridge

<a href="https://discord.gg/ykXsJKfhgq">
  <img alt="discord" src="https://img.shields.io/discord/593655374469660673?label=Discord&logo=discord&style=flat" />
</a>
<a href="https://github.com/ChainSafe/ChainBridge/actions">
  <img alt="build status" src="https://github.com/ChainSafe/ChainBridge/workflows/Tests/badge.svg?branch=master" />
</a>


# Contents
e
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Configuration](#configuration)
- [Chain Implementations](#chain-implementations)
- [Testing](#testing)ie sho
- [Simulations](#simulations)


# Installation

## Dependencies

- [Subkey](https://substrate.dev/docs/en/knowledgebase/integrate/subkey): 
Used for substrate key management. Only required if connecting to a substrate chain.


## Building

`make build`: Builds `vmbridge` in `./build`.

**or**

`make install`: Uses `go install` to add `vmbridge` to your GOBIN.

## Docker 
The official vmbridge Docker image can be found here.

To build the Docker image locally run:

```
docker build -t chainsafe/vmbridge .
```

To start vmbridge:

``` 
docker run -v ./config.json:/config.json chainsafe/vmbridge
```

# Configuration

> Note: TOML configs have been deprecated in favour of JSON

A chain configurations take this form:

```
{
    "name": "eth",                      // Human-readable name
    "type": "ethereum",                 // Chain type (eg. "ethereum" or "substrate")
    "id": "0",                          // Chain ID
    "endpoint": "ws://<host>:<port>",   // Node endpoint
    "from": "0xff93...",                // On-chain address of relayer
    "opts": {},                         // Chain-specific configuration options (see below)
}
```

See `config.json.example` for an example configuration. 

### Ethereum Options

Ethereum chains support the following additional options:

```
{
    "bridge": "0x12345...",          // Address of the bridge contract (required)
    "erc20Handler": "0x1234...",     // Address of erc20 handler (required)
    "erc721Handler": "0x1234...",    // Address of erc721 handler (required)
    "genericHandler": "0x1234...",   // Address of generic handler (required)
    "maxGasPrice": "0x1234",         // Gas price for transactions (default: 20000000000)
    "gasLimit": "0x1234",            // Gas limit for transactions (default: 6721975)
    "gasMultiplier": "1.25",         // Multiplies the gas price by the supplied value (default: 1)
    "http": "true",                  // Whether the chain connection is ws or http (default: false)
    "startBlock": "1234",            // The block to start processing events from (default: 0)
    "blockConfirmations": "10"       // Number of blocks to wait before processing a block
    "useExtendedCall": "true"        // Extend extrinsic calls to substrate with ResourceID. Used for backward compatibility with example pallet. *Default: false*
    "egsApiKey": "xxx..."            // API key for Eth Gas Station (https://www.ethgasstation.info/)
    "egsSpeed": "fast"               // Desired speed for gas price selection, the options are: "average", "fast", "fastest"
}
```

### Substrate Options

Substrate supports the following additonal options:

```
{
    "startBlock": "1234" // The block to start processing events from (default: 0)
}
```

## Blockstore

The blockstore is used to record the last block the relayer processed, so it can pick up where it left off. 

If a `startBlock` option is provided (see [Configuration](#configuration)), then the greater of `startBlock` and the latest block in the blockstore is used at startup.

To disable loading from the blockstore specify the `--fresh` flag. A custom path for the blockstore can be provided with `--blockstore <path>`. For development, the `--latest` flag can be used to start from the current block and override any other configuration.

## Keystore

vmbridge requires keys to sign and submit transactions, and to identify each bridge node on chain.

To use secure keys, see `chainbridge accounts --help`. The keystore password can be supplied with the `KEYSTORE_PASSWORD` environment variable.

To import external ethereum keys, such as those generated with geth, use `chainbridge accounts import --ethereum /path/to/key`.

To import private keys as keystores, use `chainbridge account import --privateKey key`.

For testing purposes, vmbridge provides 5 test keys. The can be used with `--testkey <name>`, where `name` is one of `Alice`, `Bob`, `Charlie`, `Dave`, or `Eve`. 

## Metrics

See [metrics.md](/docs/metrics.md).



# ChainSafe Security Policy

## Reporting a Security Bug

We take all security issues seriously, if you believe you have found a security issue within a ChainSafe
project please notify us immediately. If an issue is confirmed, we will take all necessary precautions 
to ensure a statement and patch release is made in a timely manner.

