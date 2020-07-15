# FAE
Factom-2-Ethereum bidirectional bridge

## Description

**Factom-2-Ethereum** decentralized bridge

The Ethereum to Factom bridge should be implemented as mutual smart-contract based solution, thus would provide full security of respective networks for the bridge. Currentlty, building Factom smart contract and relayer for Etheruem blockchain light verification.

## Packages

### Ethereum Side
- **FactomBridge**: Solidity smart contract for Ethereum blockchain, Factom light client storing hashes of blocks
- **FactomRelay**: Rust(?Haskell) application, streaming Factom block headers to **FactomBridge** smart contract in Ethereum blockchain.
- **FactomProver**: Solidity smart contract for Ethereum blockchain, helps verify `tx` outcome was included in in block

### Factom side
- **EthBridge**: Rust (WASM) smart contract for Factom blockchain, Ethereum light client storing hashes of blocks
- **EthRelay**: Rust(?Haskell) application, streaming Ethereum block headers to **EthBridge** smart contract in Factom blockchain.
- **EthProver**: Rust (WASM) smart contract for Factom blockchain, helps verify log entry was included in tx receipt, which was included in block
