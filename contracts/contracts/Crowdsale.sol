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
        1e24,
        4e24,
        8e24,
        9e24,
        10e24
    ];

    uint8[6] bonus = [
        70,
        30,
        25,
        10,
        5,
        0
    ];

    mapping(address => uint256) participants; // list of participants
    mapping(address => uint256) bonusAmount; // amount of bonus tokens

    event PRICE_RANGE(uint collected, uint8 idx);
    event CHUNK(uint chunk);

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor (address _tokenAddress, address _whitelistAddress, address _fundingAddress) public BasicCrowdsale(msg.sender, msg.sender) {
        basicPrice = 0.5 ether;     // NOTE: Actually is USD
        minimalGoal = 7000000 ether;   // NOTE: Actually in USD
        hardCap = 20000000 ether;      // NOTE: Actually in USD
        etherPrice = 1000 ether;     // NOTE: Actually in USD
        totalCollected = 0;

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
    
    function getTotalCollected() public view returns(uint) {
        return totalCollected;
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
    function sell(uint _value, address _recipient) internal 
    //hasBeenStarted() hasntStopped() whenCrowdsaleAlive()
    returns (uint) {
        require(whitelist.isApproved(_recipient));

        uint collected = _value.mul(etherPrice.div(1 ether));   // Collected in USD

        // Calculate change in case of hitting hard cap
        if (hardCap < totalCollected.add(collected)) {
            // Calculate change
            uint change = (collected.add(totalCollected).sub(hardCap)).div(etherPrice.div(1 ether)); // Change in ETH

            // Give change back
            _recipient.transfer(change);
            _value = _value.sub(change);    // Reduce _value by change
            collected = _value.mul(etherPrice.div(1 ether));   // Recalculate collected in USD in case of change
        }

        // Check if beyond single price range
        uint leftToSell;
        for (uint8 i = 0; i < 5 && leftToSell == 0; ++i) {  // Stop iterating if any single price range boundary hit
            if (totalCollected < priceRange[i] && priceRange[i] <= totalCollected.add(collected)) {
                uint chunk = (priceRange[i].sub(totalCollected)).div(etherPrice.div(1 ether));  // Chunk in ETH
                leftToSell = _value.sub(chunk);
                _value = chunk;
                collected = _value.mul(etherPrice.div(1 ether));   // Recalculate collected in USD in case of chunking
            }
        }

        // Sell tokens with current price
        uint tokens = _value.div(price()).mul(1e18);
        crowdsaleToken.give(_recipient, tokens);

        // Give bonus
        uint bonusTokens = 0;
        for (i = 0; i < 5 && bonusTokens == 0; ++i) {
            if (totalCollected.add(collected) <= priceRange[i]) {
                bonusTokens = tokens.mul(bonus[i]).div(100);
                emit CHUNK(bonusTokens);
            }
        }
        if (bonusTokens > 0)
            crowdsaleToken.give(address(this), bonusTokens);

        // Update counters
        totalCollected = totalCollected.add(collected);
        participants[_recipient] = participants[_recipient].add(_value);
        bonusAmount[_recipient] = bonusAmount[_recipient].add(bonusTokens);

        // Sell rest amount with another price
        if (leftToSell > 0)
            return _value.add(sell(leftToSell, _recipient));
        else
            return _value;

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
        etherPrice = usd.mul(1 ether);
    }

    // ------------------------------------------------------------------------
    // Calculates actual token price in ETH
    // ------------------------------------------------------------------------
    function price() internal view returns (uint) {
        return basicPrice.div(etherPrice.div(1 ether));
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
