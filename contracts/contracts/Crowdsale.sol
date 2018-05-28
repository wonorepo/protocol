pragma solidity ^0.4.23;

import "./SafeMath.sol";
import "../../externals/wings-integration/contracts/BasicCrowdsale.sol";
//import "wings-integration/contracts/BasicCrowdsale.sol";
import "./WonoToken.sol";
import "./Whitelist.sol";

contract Crowdsale is BasicCrowdsale {
    using SafeMath for uint;
    
    WonoToken public crowdsaleToken;
    Whitelist public whitelist;
    
    uint basicPrice;
    uint etherPrice;
    uint totalCollected;
    
    uint[5] priceRange = [
        1e6,
        4e6,
        8e6,
        9e6,
        10e6
    ];
    
    uint8[5] bonus = [
        70,
        30,
        25,
        10,
        5
    ];
    
    mapping(address => uint256) participants; // list of participants
    mapping(address => uint256) bonusAmount; // amount of bonus tokens
    
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor (address _whitelistAddress, address _tokenAddress, address _fundingAddress) public BasicCrowdsale(msg.sender, msg.sender) {
        basicPrice = 0.5 ether;     // NOTE: Actually is USD
        minimalGoal = 7000 ether;   // NOTE: Actually in USD
        hardCap = 20000 ether;      // NOTE: Actually in USD
        etherPrice = 500 ether;     // NOTE: Actually in USD
        
        crowdsaleToken = WonoToken(_tokenAddress);
        whitelist = Whitelist(_whitelistAddress);
        fundingAddress = _fundingAddress; // Where all Ether will be funded
    }
    
    // ------------------------------------------------------------------------
    // Various getters
    // ------------------------------------------------------------------------
    function getToken() public returns(address) {
        return crowdsaleToken;
    }
    
    function getWhitelist() public view returns(address) {
        return whitelist;
    }
    
    // ------------------------------------------------------------------------
    // Accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        require(msg.value > 0);
        sell(msg.value, msg.sender);
    }
    
    // ------------------------------------------------------------------------
    // Token distribution method
    // ------------------------------------------------------------------------
    function sell(uint _value, address _recipient) internal hasBeenStarted() hasntStopped() whenCrowdsaleAlive() returns (uint) {
        //require(whitelist.isApproved(_recipient);
    
        uint collected = _value.mul(etherPrice);   // Collected in USD
    
        // Calculate change in case of hitting hard cap
        if (hardCap < totalCollected.add(collected)) {
            // Calculate change
            uint change = (collected.add(totalCollected).sub(hardCap)).div(etherPrice); // Change in ETH

            // Give change back
            _recipient.transfer(change);
            _value = _value.sub(change);    // Reduce _value by change
            collected = _value.mul(etherPrice);   // Recalculate collected in USD in case of change
        }


        // Check if beyond single price range
        uint leftToSell;
        for (uint8 i = 0; i < 5 && leftToSell == 0; ++i) {  // Stop iterating if any single price range boundary hit
            if (totalCollected < priceRange[i] && priceRange[i] <= totalCollected.add(collected)) {
                uint chunk = (priceRange[i].sub(totalCollected)).div(etherPrice);
                leftToSell = _value.sub(chunk);
                _value = chunk;
            }
        }
        
        // Sell tokens with current price
        uint tokens = _value.div(price());
        crowdsaleToken.give(msg.sender, tokens);
        
        // Update counters
        totalCollected = totalCollected.add(collected);
        participants[msg.sender] = participants[msg.sender].add(_value);
        bonusAmount[msg.sender] = bonusAmount[msg.sender].add(calculateBonus(_value));
        
        // Sell rest amount with another price
        if (leftToSell > 0)
            return _value + sell(leftToSell, _recipient);
        else
            return _value;
        
    }
    
    // ------------------------------------------------------------------------
    // Calculate bonus
    // ------------------------------------------------------------------------
    function calculateBonus(uint _value) internal view returns(uint) {
        uint collected = _value.mul(etherPrice);
        for (uint8 i = 0; i < 5; ++i) {
            if (totalCollected < priceRange[i] && priceRange[i] <= totalCollected.add(collected)) {
                return bonus[i];
            }
        }
        return 0;
    }
    
    // ------------------------------------------------------------------------
    // Get total bonus amount
    // ------------------------------------------------------------------------
    function getBonus() public view returns(uint) {
        return bonusAmount[msg.sender];
    }

    // ------------------------------------------------------------------------
    // Get bonus amount available
    // ------------------------------------------------------------------------
    function getBonusAvailable() public view returns(uint) {
        return bonusAmount[msg.sender]; // FIXME recalculate with date
    }

    // ------------------------------------------------------------------------
    // Update actual ETH price
    // ------------------------------------------------------------------------
    function updateEtherPrice(uint usd) public onlyOwner {
        etherPrice = usd;
    }
    
    
    // ------------------------------------------------------------------------
    // Calculates actual token price in ETH
    // ------------------------------------------------------------------------
    function price() internal view returns (uint) {
        return basicPrice / etherPrice / uint(10) ** crowdsaleToken.decimals();
    }
    
    function mintETHRewards(address forecasting, uint eth) public onlyManager()
    {
        
    }
    
    function mintTokenRewards(address forecasting, uint tokens) public onlyManager()
    {
        crowdsaleToken.give(forecasting, tokens);
    }
    
    function releaseTokens() public // onlyManager() hasntStopped() whenCrowdsaleSuccessful()
    {
        crowdsaleToken.release();
    }
    
    function stop() public onlyManager() hasntStopped()
    {
    
    }
    
    function start(uint256 _startTimestamp, uint256 _endTimestamp, address _fundingAddress) public onlyManager() hasntStopped()
    {
    
    }
    
    function withdraw(uint eth) public onlyOwner() hasntStopped() whenCrowdsaleSuccessful() {
        require(eth <= address(this).balance);
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
