pragma solidity ^0.4.23;

import "./ERC20Interface.sol";
import "./SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./ApproveAndCallFallBack.sol";

contract WonoToken is ERC20Interface, Ownable {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    bool public transferUnlocked;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "WONO";
        name = "WONO Token";
        decimals = 18;
        transferUnlocked = false;
        _totalSupply = uint(47500000).mul(uint(10) ** uint(decimals));
        balances[this] = _totalSupply;
    }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
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
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public transfersAllowed returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public transfersAllowed returns (bool success) {
//        require(allowed[from][msg.sender] >= tokens);
//        require(balances[from] >= tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }

    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }

    // ------------------------------------------------------------------------
    // Owner can create any amount of tokens from a thin air
    // ------------------------------------------------------------------------
    function issue(uint tokens) public onlyOwner transfersLocked {
        require(!transferUnlocked);
        balances[this] = balances[this].add(tokens);
        _totalSupply = _totalSupply.add(tokens);
    }
    
    // ------------------------------------------------------------------------
    // Owner can destroy any amount of tokens from zero address balance
    // ------------------------------------------------------------------------
    function sterilize(uint tokens) public onlyOwner {
        balances[address(0)] = balances[address(0)].sub(tokens);
        _totalSupply = _totalSupply.sub(tokens);
    }
    
    // ------------------------------------------------------------------------
    // Allow transfers
    // ------------------------------------------------------------------------
    function release() public // onlyOwner
    {
        transferUnlocked = true;
    }
    
    // ------------------------------------------------------------------------
    // Give tokens
    // ------------------------------------------------------------------------
    function give(address recipient, uint tokens) public onlyOwner transfersLocked {
        balances[this] = balances[this].sub(tokens);
        balances[recipient] = balances[recipient].add(tokens);
    }
}
