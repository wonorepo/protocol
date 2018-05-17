pragma solidity ^0.4.23;

import "./SafeMath.sol";
import "wings-integration/contracts/BasicCrowdsale.sol";
import "./WonoToken.sol";
import "./Whitelist.sol";

contract Crowdsale is BasicCrowdsale, Owned {
    using SafeMath for uint;
    
    WonoToken public crowdsaleToken;
    Whitelist public whitelist;
    
    uint basicPrice = 0.5 ether;
    uint etherPrice = 750 ether;
    uint totalCollectedUSD = 0;
    
    uint[4] priceRange = [
        3e6,
        7e6,
        8e6,
        9e6
    ];
    
    uint8[4] discount = [
        70,
        75,
        90,
        95
    ];
    
    mapping(address => uint256) participants; // list of participants
    
    constructor (address _whitelistAddress, address _tokenAddress, address _fundingAddress) public BasicCrowdsale(msg.sender, msg.sender) {
        basicPrice = 0.5 ether;
        minimalGoal = 7000 ether;
        hardCap = 20000 ether;
        
        crowdsaleToken = WonoToken(_tokenAddress);
        whitelist = Whitelist(_whitelistAddress);
        fundingAddress = _fundingAddress; // Where all Ether will be funded
    }
    
    function getToken() public returns(address) {
        return crowdsaleToken;
    }
    
    function () public payable {
        require(msg.value > 0);
        participate(msg.value, msg.sender);
    }
    
    function participate(uint _value, address _recipient) internal hasBeenStarted() hasntStopped() whenCrowdsaleAlive() returns (uint) {
        if (hardCap < totalCollected + _value) {
            // Calculate change
            uint change = _value + totalCollected - hardCap;

            // Give change back
            _recipient.transfer(change);
            _value = _value - change;
        }
        
        // Calculate USD funded
        uint collectedUSD = _value * etherPrice;
        
        
        // Check price range
        uint leftToSell = 0;
        for (uint8 i = 0; i < 4 && leftToSell == 0; ++i) {
            if (totalCollectedUSD < priceRange[i] && priceRange[i] <= totalCollectedUSD + collectedUSD) {
                uint chunk = (priceRange[i] - totalCollectedUSD) / etherPrice;
                leftToSell = _value - chunk;
                _value = chunk;
            }
        }
        
        // Sell tokens with current price
        uint tokens = _value * price();
        crowdsaleToken.give(msg.sender, tokens);
        
        // Update counters
        totalCollected += _value;
        totalCollectedUSD += collectedUSD;
        
        // Sell rest amount with another price
        if (leftToSell > 0)
            return _value + participate(leftToSell, _recipient);
        else
            return _value;
        
    }
    
    function updateEtherPrice(uint usd) public onlyOwner {
        etherPrice = usd;
    }
    
    function price() internal view returns (uint) {
        uint _price = basicPrice / etherPrice / uint(10) ** crowdsaleToken.decimals();
        for (uint8 i = 0; i < 4; ++i) {
            if (totalCollectedUSD < priceRange[i])
                return discount[i] / 100 * _price;
        }
        return _price;
    }
}
