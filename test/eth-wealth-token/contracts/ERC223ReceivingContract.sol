pragma solidity ^0.6;

contract ERC223ReceivingContract {
    function tokenFallback(
        address from,
        uint256 value,
        bytes data
    ) public;
}
