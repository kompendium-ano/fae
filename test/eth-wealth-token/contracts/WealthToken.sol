pragma solidity ^0.6;

import "./BaseToken.sol";
import "./ERC223Interface.sol";
import "./ERC223ReceivingContract.sol";

contract Standard223Token is ERC223, StandardToken {
    //function that is called when a user or another contract wants to transfer funds
    function transfer(
        address _to,
        uint256 _value,
        bytes _data
    ) returns (bool success) {
        //filtering if the target is a contract with bytecode inside it
        if (!super.transfer(_to, _value)) throw; // do a normal token transfer
        if (isContract(_to))
            return contractFallback(msg.sender, _to, _value, _data);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value,
        bytes _data
    ) returns (bool success) {
        if (!super.transferFrom(_from, _to, _value)) throw; // do a normal token transfer
        if (isContract(_to)) return contractFallback(_from, _to, _value, _data);
        return true;
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        return transfer(_to, _value, new bytes(0));
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) returns (bool success) {
        return transferFrom(_from, _to, _value, new bytes(0));
    }

    //function that is called when transaction target is a contract
    function contractFallback(
        address _origin,
        address _to,
        uint256 _value,
        bytes _data
    ) private returns (bool success) {
        ERC223Receiver reciever = ERC223Receiver(_to);
        return reciever.tokenFallback(msg.sender, _origin, _value, _data);
    }

    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private returns (bool is_contract) {
        // retrieve the size of the code on target address, this needs assembly
        uint256 length;
        assembly {
            length := extcodesize(_addr)
        }
        return length > 0;
    }
}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is Standard223Token {
    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(burner, _value);
    }
}

contract WealthToken is ERC223Interface, BaseToken {
    // Publicly listed name
    string public name = "WealthToken";
    // Symbol under which token will be trading
    string public symbol = "WLT";
    // 1 ETH consists of 10^18 Wei, which is the smallest ETH unit
    //   uint8 public decimals = 18;
    // Defining the value of a million for easy calculations - order of declaration matters (hoisting)
    //   uint256 million = 1000000 * (10 ** uint256(decimals));
    // We are offering a total of 100 Million tokens to distribute
    uint256 public totalSupply = 40000 * 1000000 * 10**18;
    // Address where all the tokens are held, as tokens aren't held within the Smart Contract
    address public masterWallet;

    // constructor function
    constructor(string _symbol, string _name) public {
        // The wallet from which the contract is deployed, also the owner of the contract
        owner = msg.sender;
        masterWallet = owner;

        // Assign total supply to master wallet
        // https://github.com/OpenZeppelin/zeppelin-solidity/issues/494
        // A token contract which creates new tokens SHOULD trigger a Transfer event with the _from address set to 0x0 when tokens are created.
        balances[masterWallet] = totalSupply;
        emit Transfer(0x0, masterWallet, totalSupply);
    }
}
