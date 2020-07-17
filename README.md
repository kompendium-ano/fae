# FAE

Factom-2-Ethereum bidirectional bridge. Main idea is to re-use smart-contracts functionality from Ethereum and Factom platforms and allow calling contracts and data from one system to another. For the current setup, we forsee 2 main cases:

- transferring ERC20, ERC-721, ERC-1155 from Ethereum to Factom via FAT
- storing data of Factom, calling it from Ethereum side
- calling Ethereum contract from Factom via FAT

## Description

**Factom-2-Ethereum** decentralized bridge

The Ethereum to Factom bridge should be implemented as mutual smart-contract based solution, thus would provide full security of respective networks for the bridge. Currentlty, building Factom smart contract and relayer for Etheruem blockchain light verification.

## Structure

- `ethereum` - everything related to the Ethereum side of the system
- `factom`   - everything related to the Factom side of the system
- `docs`     - additional documentation for the project
- `app`      - example app for ERC20 token transfer with some simplistic UI

### Ethereum Side
- **FactomBridge**: Solidity smart contract for Ethereum blockchain, Factom light client storing hashes of blocks
- **FactomRelay**: an application, streaming Factom block headers to **FactomBridge** smart contract in Ethereum blockchain.
- **FactomProver**: Solidity smart contract for Ethereum blockchain, helps verify `tx` outcome was included in in block

### Factom side
- **EthBridge**: WASM smart contract for Factom blockchain, Ethereum light client storing hashes of blocks
- **EthRelay**: application, streaming Ethereum block headers to **EthBridge** smart contract in Factom blockchain.
- **EthProver**: W smart contract for Factom blockchain, helps verify log entry was included in tx receipt, which was included in block

## Workflow
