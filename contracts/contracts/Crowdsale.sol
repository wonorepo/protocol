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
    uint totalCollected = 0;
    
    uint[4] priceRange = [
        3e6,
        7e6,
        8e6,
        9e6
    ];
    
    uint8[4] bonus = [
        130,
        125,
        110,
        105
    ];
    
    mapping(address => uint256) participants; // list of participants
    
    constructor (address _whitelistAddress, address _tokenAddress, address _fundingAddress) public BasicCrowdsale(msg.sender, msg.sender) {
        basicPrice = 0.5 ether;     // NOTE: Actually is USD
        minimalGoal = 7000 ether;   // NOTE: Actually in USD
        hardCap = 20000 ether;      // NOTE: Actually in USD
        etherPrice = 700 ether;     // NOTE: Actually in USD
        
        crowdsaleToken = WonoToken(_tokenAddress);
        whitelist = Whitelist(_whitelistAddress);
        fundingAddress = _fundingAddress; // Where all Ether will be funded
    }
    
    function getToken() public returns(address) {
        return crowdsaleToken;
    }
    
    function () public payable {
        require(msg.value > 0);
        sell(msg.value, msg.sender);
    }
    
    function sell(uint _value, address _recipient) internal hasBeenStarted() hasntStopped() whenCrowdsaleAlive() returns (uint) {
        //require(whitelist.isApproved(_recipient);
    
        uint collected = _value * etherPrice;
    
        // Calculate change
        if (hardCap < totalCollected + collected) {
            // Calculate change
            uint changeETH = (collected + totalCollected - hardCap) / etherPrice;

            // Give change back
            _recipient.transfer(changeETH);
            _value = _value - changeETH;
        }


        // Check if beyond single price range
        uint leftToSell = 0;
        for (uint8 i = 0; i < 4 && leftToSell == 0; ++i) {
            if (totalCollected < priceRange[i] && priceRange[i] <= totalCollected + collected) {
                uint chunk = (priceRange[i] - totalCollected) / etherPrice;
                leftToSell = _value - chunk;
                _value = chunk;
            }
        }
        
        // Sell tokens with current price
        uint tokens = _value * etherPrice * price();
        crowdsaleToken.give(msg.sender, tokens);
        
        // Update counters
        totalCollected += collected;
        
        // Sell rest amount with another price
        if (leftToSell > 0)
            return _value + sell(leftToSell, _recipient);
        else
            return _value;
        
    }
    
    function updateEtherPrice(uint usd) public onlyOwner {
        etherPrice = usd;
    }
    
    function price() internal view returns (uint) {
        uint _price = basicPrice / etherPrice / uint(10) ** crowdsaleToken.decimals();
        for (uint8 i = 0; i < 4; ++i) {
            if (totalCollected < priceRange[i])
                return bonus[i] / 100 * _price;
        }
        return _price;
    }
    
    function mintETHRewards(address forecasting, uint eth) public onlyManager()
    {
        
    }
    
    function mintTokenRewards(address forecasting, uint tokens) public onlyManager()
    {
        crowdsaleToken.give(forecasting, tokens);
    }
    
    function releaseTokens() public onlyManager() hasntStopped() whenCrowdsaleSuccessful()
    {
        crowdsaleToken.release();
    }
    
    function stop() public onlyManager() hasntStopped()
    {
    
    }
    
    function start(uint256 _startTimestamp, uint256 _endTimestamp, address _fundingAddress) 
    {
    
    }
    
    function withdraw(uint eth) public onlyOwner() hasntStopped() whenCrowdsaleSuccessful() {
        require(eth <= this.balance);
        fundingAddress.transfer(eth);
    }
    
    // backers refund their ETH if the crowdsale was cancelled or has failed
    function refund() public {
        // either cancelled or failed
        require(stopped || isFailed());

        uint amount = participants[msg.sender];

        // prevent from doing it twice
        require(amount > 0);
        participants[msg.sender] = 0;

        msg.sender.transfer(amount);
    }
}
