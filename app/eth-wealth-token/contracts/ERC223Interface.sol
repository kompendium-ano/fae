/**
 * ERC223 additions to ERC20
 *
 * Interface wise is ERC20 + data paramenter to transfer and transferFrom.
 */
contract ERC223 is ERC20 {
    function transfer(
        address to,
        uint256 value,
        bytes data
    ) returns (bool ok);

    function transferFrom(
        address from,
        address to,
        uint256 value,
        bytes data
    ) returns (bool ok);
}

/**
 *  Base class contracts willing to accept ERC223 token transfers must conform to.
 */
contract ERC223Receiver {
    function tokenFallback(
        address _sender,
        address _origin,
        uint256 _value,
        bytes _data
    ) returns (bool ok);
}
