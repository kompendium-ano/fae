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

     

}