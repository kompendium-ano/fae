pragma solidity ^0.6;


interface IFactomBridge {
    event BlockHashAdded(
        uint64 indexed height,
        bytes32 blockHash
    );

    event BlockHashReverted(
        uint64 indexed height,
        bytes32 blockHash
    );

    function blockHashes(uint64 blockNumber) external view returns(bytes32);
    function blockMerkleRoots(uint64 blockNumber) external view returns(bytes32);

    function balanceOf(address wallet) external view returns(uint256);
    function deposit() external payable;
    function withdraw() external;

    function initWithValidators(bytes calldata initialValidators) external;
    function initWithBlock(bytes calldata data) external;
    function initEmpty(bytes calldata) external;

}
