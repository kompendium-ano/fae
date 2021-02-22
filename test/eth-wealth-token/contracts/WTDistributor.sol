pragma solidity ^0.6;

import "./Ownable.sol";
import "./WealthToken.sol";

// automatic airdrop/distribution based on the list
contract WTDistributor is Ownable {
    WealthToken dc;

    function setContractAddress(address _t) public onlyOwner {
        dc = WealthToken(_t);
    }

    function distributeTokens(address[] dests, uint256 amount)
        public
        onlyOwner
        returns (uint256)
    {
        uint256 i = 0;
        while (i < dests.length) {
            dc.transferFrom(msg.sender, dests[i], amount);
            i += 1;
        }
        return (i);
    }
}
