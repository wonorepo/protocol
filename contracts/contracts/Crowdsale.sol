pragma solidity ^0.4.23;

import "./SafeMath.sol";
import "wings-integration/contracts/BasicCrowdsale.sol";
import "./WonoToken.sol";

contract Crowdsale is BasicCrowdsale, Owned {
    using SafeMath for uint;
    
    WonoToken public crowdsaleToken;
    
    uint etherPrice = 750 ether;
    uint totalCollectedUSD = 0;
    
    mapping(address => uint256) participants; // list of participants
    
    constructor (address _tokenAddress, address _fundingAddress) BasicCrowdsale(msg.sender, msg.sender) {
        basicPrice = 0.5 ether;
        minimalGoal = 7000 ether;
        hardCap = 20000 ether;
        
        crowdsaleToken = WonoToken(_tokenAddress);
        fundingAddress = _fundingAddress; // Where all Ether will be funded
    }
    
    function getToken() public returns(address) {
        return crowdsaleToken;
    }
    
    function() payable {
        require(msg.value > 0);
        participate(msg.value, msg.sender);
    }
    
    function participate(uint _value, address _recipient) internal hasBeenStarted() hasntStopped() whenCrowdsaleAlive() {
        if (hardCap < totalCollected + _value) {
            // Calculate change
            uint change = _value + totalCollected - hardCap;

            // Give change back
            _recipient.transfer(change);
            _value = _value - change;
        }
        
        uint tokensSold = 0;
        
        // Calculate tokens sold
        
        // Calculate USD funded
        
        
    }
    
    function updateEtherPrice(uint usd) public onlyOwner {
        etherPrice = usd;
    }
    
    function price() public returns (uint) {
        uint _price = basicPrice / etherPrice;
        uint8 discount = 100;
        if (totalCollectedUSD < 3000000)
            discount = 70;
        else if (totalCollectedUSD < 7000000)
            discount = 75;
        else if (totalCollectedUSD < 8000000)
            discount = 90;
        else if (totalCollectedUSD < 9000000)
            discount = 95;
        return _price * discount / 100;
    }
}
