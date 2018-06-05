pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC827/ERC827Token.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract WonoToken is ERC827Token, DetailedERC20, Ownable  {
    using SafeMath for uint;

    bool public transferUnlocked;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public DetailedERC20("WONO Token", "WONO", 18) {
        transferUnlocked = false;
        totalSupply_ = uint(47500000).mul(uint(10) ** uint(decimals));
        balances[this] = totalSupply_;
    }

    // ------------------------------------------------------------------------
    // Transfers allowed modifiers
    // ------------------------------------------------------------------------
    modifier transfersAllowed() {
        require(transferUnlocked);
        _;
    }

    modifier transfersLocked() {
        require(!transferUnlocked);
        _;
    }

    // ------------------------------------------------------------------------
    // Overload transfers
    // ------------------------------------------------------------------------
    function transfer(address _to, uint _value) public transfersAllowed returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public transfersAllowed returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }


    function approve(address _spender, uint _value) public transfersAllowed returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public transfersAllowed returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public transfersAllowed returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }

    // ------------------------------------------------------------------------
    // Owner can create any amount of tokens from a thin air
    // ------------------------------------------------------------------------
    function issue(uint tokens) public onlyOwner transfersLocked {
        require(!transferUnlocked);
        balances[this] = balances[this].add(tokens);
        totalSupply_ = totalSupply_.add(tokens);
    }

    // ------------------------------------------------------------------------
    // Owner can destroy any amount of tokens from zero address balance
    // ------------------------------------------------------------------------
    function sterilize(uint tokens) public onlyOwner {
        balances[address(0)] = balances[address(0)].sub(tokens);
        totalSupply_ = totalSupply_.sub(tokens);
    }

    // ------------------------------------------------------------------------
    // Allow transfers
    // ------------------------------------------------------------------------
    function release() public onlyOwner
    {
        transferUnlocked = true;
    }

    // ------------------------------------------------------------------------
    // Give tokens
    // ------------------------------------------------------------------------
    function give(address _to, uint _value) public onlyOwner transfersLocked {
        balances[this] = balances[this].sub(_value);
        balances[_to] = balances[_to].add(_value);
    }
}
