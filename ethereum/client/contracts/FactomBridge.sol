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

    function initWithBlock(bytes memory data) public override {
        require(
            currentBlockProducers.totalStake > 0,
            "FactomBridge: validators need to be initialized first"
        );
        require(!initialized, "FactomBridge: already initialized");
        initialized = true;

        Data memory borsh = from(data);
        FactomDecoder.LightClientBlock memory factomBlock = data
            .decodeLightClientBlock();
        require(
            borsh.finished(),
            "FactomBridge: only light client block should be passed as first argument"
        );

        require(
            !factomBlock.next_vals.none,
            "FactomBridge: Initialization block should contain next_vals."
        );
        setBlock(factomBlock, head);
        // setBlockProducers(factomBlock.next_block_vals.validatorEntries, nextBlockProducers);
        blockHashes_[head.height] = head.hash;
        blockMerkleRoots_[head.height] = head.merkleRoot;
    }

    // Fill out required block information
    function setBlock(
        FactomDecoder.LightClientBlock memory src,
        BlockInfo storage dest
    ) internal {
        dest.height = src.inner_lite.height;
        dest.timestamp = src.inner_lite.timestamp;

        dest.next_hash = src.next_hash;

        emit BlockHashAdded(src.inner_lite.height, src.hash);
    }

    function commitBlock() internal {
        require(
            lastValidAt != 0 && block.timestamp >= lastValidAt,
            "Nothing to commit"
        );

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

    function _checkValidatorSignature(
        uint64 height,
        bytes32 next_block_hash,
        FactomDecoder.Signature memory signature,
        FactomDecoder.PublicKey storage publicKey
    ) internal view returns (bool) {
        bytes memory message = abi.encodePacked(
            uint8(0),
            next_block_hash,
            _reversedUint64(height + 2),
            bytes23(0)
        );

        if (signature.enumIndex == 0) {
            (bytes32 arg1, bytes9 arg2) = abi.decode(
                message,
                (bytes32, bytes9)
            );
            return
                publicKey.ed25519.xy != bytes32(0) &&
                edwards.check(
                    publicKey.ed25519.xy,
                    signature.ed25519.rs[0],
                    signature.ed25519.rs[1],
                    arg1,
                    arg2
                );
        } else {
            return
                ecrecover(
                    keccak256(message),
                    signature.secp256k1.v +
                        (signature.secp256k1.v < 27 ? 27 : 0),
                    signature.secp256k1.r,
                    signature.secp256k1.s
                ) ==
                address(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                publicKey.secp256k1.x,
                                publicKey.secp256k1.y
                            )
                        )
                    )
                );
        }
    }

    function _reversedUint64(uint64 data) private pure returns (uint64 r) {
        r = data;
        r = ((r & 0x00000000FFFFFFFF) << 32) | ((r & 0xFFFFFFFF00000000) >> 32);
        r = ((r & 0x0000FFFF0000FFFF) << 16) | ((r & 0xFFFF0000FFFF0000) >> 16);
        r = ((r & 0x00FF00FF00FF00FF) << 8) | ((r & 0xFF00FF00FF00FF00) >> 8);
    }

    function blockHashes(uint64 height)
        public
        override
        view
        returns (bytes32 res)
    {
        res = blockHashes_[height];
        if (
            res == 0 &&
            block.timestamp >= lastValidAt &&
            lastValidAt != 0 &&
            height == untrustedHead.height
        ) {
            res = untrustedHead.hash;
        }
    }

    function blockMerkleRoots(uint64 height)
        public
        override
        view
        returns (bytes32 res)
    {
        res = blockMerkleRoots_[height];
        if (
            res == 0 &&
            block.timestamp >= lastValidAt &&
            lastValidAt != 0 &&
            height == untrustedHead.height
        ) {
            res = untrustedHead.merkleRoot;
        }
    }

    // Check that the new block is signed by more than 2/3 of the validators.
    checkSignByValidators(factomBlock, factomBlockIsFromNextBlock ? nextBlockProducers : currentBlockProducers);

        // If the block is from the next Block, make sure that next_bps is supplied and has a correct hash.
        if (factomBlockIsFromNextBlock) {
            require(
                !factomBlock.next_bps.none,
                "FactomBridge: Next next_bps should not be None"
            );
            require(
                factomBlock.next_bps.hash == factomBlock.inner_lite.next_bp_hash,
                "FactomBridge: Hash of block producers does not match"
            );
        }
}
