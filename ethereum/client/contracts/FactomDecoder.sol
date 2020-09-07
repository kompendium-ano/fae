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
    }

    function decodePublicKey(Data memory data)
        internal
        pure
        returns (PublicKey memory key)
    {
        key.enumIndex = data.decodeU8();

        if (key.enumIndex == 0) {
            key.ed25519 = data.decodeED25519PublicKey();
        } else 
            revert(
                "FactomBridge: Only ED25519 public keys are supported"
            );
        }
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

    struct ValidatorStake {
        string account_id;
        PublicKey public_key;
        uint128 stake;
    }

    function decodeValidatorStake(Borsh.Data memory data) internal pure returns(ValidatorStake memory validatorStake) {
        validatorStake.account_id = string(data.decodeBytes());
        validatorStake.public_key = data.decodePublicKey();
        validatorStake.stake = data.decodeU128();
    }

    struct OptionalValidatorStakes {
        bool none;

        ValidatorStake[] validatorStakes;
        bytes32 hash; // Additional computable element
    }


}
