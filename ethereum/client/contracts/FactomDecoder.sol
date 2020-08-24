pragma solidity ^0.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Ed25519.sol";

// decode input messages
contract FactomDecoder {
    using SafeMath for uint256;

    struct PublicKey {
        uint8 enumIndex;

        ED25519PublicKey ed25519;
        SECP256K1PublicKey secp256k1;
    }

     function decodePublicKey(Data memory data) internal pure returns(PublicKey memory key) {
         // TODO: decode from data
     }

     struct LightClientBlock {
        bytes32 prev_block_hash;
        bytes32 next_block_inner_hash;
        BlockHeaderInnerLite inner_lite;
        bytes32 inner_rest_hash;
        //OptionalValidatorStakes next_block_vals; // we want to incentivize validators through staking
        OptionalSignature[] approvals_after_next;

        bytes32 hash;
        bytes32 next_hash;
    }

}