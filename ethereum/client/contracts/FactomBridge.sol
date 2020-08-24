pragma solidity ^0.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./IFactomBridge.sol";
import "./Ed25519.sol";

contract FactomBridge is IFactomBridge {
    using SafeMath for uint256;

    struct BlockProducer {
        // publicKey;
        uint128 stake;
    }

    // Minimal information about the submitted block.
    struct BlockInfo {
        uint64 height;
        uint256 timestamp;
        bytes32 dBlockId;
        bytes32 nextDBlockId;
        bytes32 hash;
        bytes32 merkleRoot;
        bytes32 next_hash;
    }

    // Whether the contract was initialized.
    bool public initialized;
    address payable burner;
    uint256 public lockEthAmount;
    uint256 public lockDuration;
    uint256 public replaceDuration; // as nanoseconds
    Ed25519 edwards;

    BlockProducerInfo currentBlockProducers;
    BlockProducerInfo nextBlockProducers;

    BlockInfo head;
    BlockInfo untrustedHead;

    mapping(uint64 => bytes32) blockHashes_;
    mapping(uint64 => bytes32) blockMerkleRoots_;
    mapping(address => uint256) public override balanceOf;

    event BlockHashAdded(uint64 indexed height, bytes32 blockHash);

    event BlockHashReverted(uint64 indexed height, bytes32 blockHash);

    constructor(
        Ed25519 ed,
        uint256 lockEthAmount_,
        uint256 lockDuration_,
        uint256 replaceDuration_
    ) public {
        edwards = ed;
        lockEthAmount = lockEthAmount_;
        lockDuration = lockDuration_;
        replaceDuration = replaceDuration_;
        burner = address(0);
    }

    function deposit() public override payable {
        require(msg.value == lockEthAmount && balanceOf[msg.sender] == 0);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(msg.value);
    }

    function withdraw() public override {
        require(msg.sender != lastSubmitter || block.timestamp >= lastValidAt);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(lockEthAmount);
        msg.sender.transfer(lockEthAmount);
    }

    function challenge(address payable receiver, uint256 signatureIndex)
        public
        override
    {
        require(
            block.timestamp < lastValidAt,
            "No block can be challenged at this time"
        );

        require(
            !checkBlockProducerSignatureInHead(signatureIndex),
            "Can't challenge valid signature"
        );

        _payRewardAndRollBack(receiver);
    }

   function initWithBlock(bytes memory data) override public {
        require(currentBlockProducers.totalStake > 0, "FactomBridge: validators need to be initialized first");
        require(!initialized, "FactomBridge: already initialized");
        initialized = true;

        Data memory borsh = from(data);
        FactomDecoder.LightClientBlock memory nearBlock = data.decodeLightClientBlock();
        require(borsh.finished(), "FactomBridge: only light client block should be passed as first argument");

        require(!nearBlock.next_vals.none, "FactomBridge: Initialization block should contain next_vals.");
        setBlock(nearBlock, head);
        // setBlockProducers(nearBlock.next_block_vals.validatorEntries, nextBlockProducers);
        blockHashes_[head.height] = head.hash;
        blockMerkleRoots_[head.height] = head.merkleRoot;
    }

    // Fill out required block information
    function setBlock(FactomDecoder.LightClientBlock memory src, BlockInfo storage dest) internal {
        dest.height = src.inner_lite.height;
        dest.timestamp = src.inner_lite.timestamp;

        dest.next_hash = src.next_hash;

        emit BlockHashAdded(
            src.inner_lite.height,
            src.hash
        );
    }

    function commitBlock() internal {
        require(lastValidAt != 0 && block.timestamp >= lastValidAt, "Nothing to commit");

        head = untrustedHead;
        if (untrustedHeadIsFromNextBlock) {
            // Switch to the next block. It is guaranteed that untrustedNextBlockProducers is set.
            copyBlockProducers(nextBlockProducers, currentBlockProducers);
            copyBlockProducers(untrustedNextBlockProducers, nextBlockProducers);
        }
        lastValidAt = 0;

        blockHashes_[head.height] = head.hash;
        blockMerkleRoots_[head.height] = head.merkleRoot;
    }

}
