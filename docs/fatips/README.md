# FATIPs - FAT proposals

Before submitting for community review, we need to do internal investigation and expimentation to work out several potential solutions.

## FATIP XX1 - Cross-contract Calls 

a special protocol to allow smart-contracts call functions from each one. That means for users that smart-contracts can be extended with the addition of new smart-contracts without compromising those already deployed. This Improvement Proposal introduces calls and visibility functionality to let the developer identify the interface that can be called. To execute these calls a gas system is required, which is described below in FATIP 3 - Contracts Gas system. Technically the call interface is similar to Ethereum with a minimal set of arguments such as call(<chainid of the token>, <token contract address>, <function to call>, <args(..)>)

## FATIP XX2 - Extendable Contract Storage 

Smart contracts are not currently stateful inside the FAT ecosystem. This extendable storage solution brings in contract state into contract storage and allows the ability to store user data. To be stateful means that some amount of storage on the chain is used to store values. This storage can be either global or local. Local storage refers to storing values in an accounts balance record if that account participates in the contract. Global storage is data that is specifically stored on the blockchain for the contract globally and can be retrieved on demand. 

## FATIP XX3 - Contracts Gas system 

The potential use of Factom Entry Credits (EC) as a smart- contract Gas mechanism. For example, FAT-1 Transactions require Gas due to their expensive execution nature. The main idea is to lock a specific amount of FCT from the user for the tx, burn FCT to generate the required amount of EC for the tx, and use leftover FCT as tx fee paid to the node processing the tx or contact calls.
