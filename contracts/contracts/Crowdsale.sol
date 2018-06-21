pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../../externals/wings-integration/contracts/BasicCrowdsale.sol";
import "./WonoToken.sol";
import "./Whitelist.sol";

contract Crowdsale is BasicCrowdsale {
    using SafeMath for uint;

    WonoToken public crowdsaleToken;
    Whitelist public whitelist;

    uint basicPrice;
    uint etherPrice;

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

    struct Participant {
        uint funded;
        uint sold;
        uint bonus;
        uint claimed;
    }

    mapping(address => Participant) participants; // list of participants

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor (address _tokenAddress, address _whitelistAddress) public BasicCrowdsale(msg.sender, msg.sender) {
        basicPrice = 0.5 ether;         // NOTE: Actually is USD
        minimalGoal = 8000000 ether;    // NOTE: Actually in USD
        hardCap = 21000000 ether;       // NOTE: Actually in USD
        etherPrice = 1000 ether;        // NOTE: Actually in USD
        totalCollected = 0;

        crowdsaleToken = WonoToken(_tokenAddress);
        whitelist = Whitelist(_whitelistAddress);
    }

    // ------------------------------------------------------------------------
    // Returns whitelist address
    // ------------------------------------------------------------------------
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
        participants[_recipient].sold.add(tokens);
        crowdsaleToken.give(_recipient, tokens);

        // Give bonus
        uint bonusTokens = 0;
        for (i = 0; i < 5 && bonusTokens == 0; ++i) {
            if (totalCollected.add(collected) <= priceRange[i]) {
                bonusTokens = tokens.mul(bonus[i]).div(100);
            }
        }
        if (bonusTokens > 0) {
            participants[_recipient].bonus.add(bonusTokens);
            crowdsaleToken.give(address(this), bonusTokens);
        }

        // Update counters
        totalCollected = totalCollected.add(collected);
        participants[_recipient].funded = participants[_recipient].funded.add(_value);

        // Sell rest amount with another price
        if (leftToSell > 0)
            return _value.add(sell(leftToSell, _recipient));
        else
            return _value;
    }

    // ------------------------------------------------------------------------
    // Get tokens bought by sender
    // ------------------------------------------------------------------------
    function getBought() public view returns(uint) {
        return participants[msg.sender].sold;
    }
    
    // ------------------------------------------------------------------------
    // Get bonus amount for sender
    // ------------------------------------------------------------------------
    function getBonus() public view returns(uint) {
        return participants[msg.sender].bonus;
    }

    // ------------------------------------------------------------------------
    // Get bonus amount available to withdrawal for sender
    // ------------------------------------------------------------------------
    function getBonusAvailable() public view returns(uint) {
        uint available = 0;
        for (uint8 i = 0; i < 5; ++i)
            // Each 60 days
            if (block.timestamp >= endTimestamp.add(uint(86400).mul(60).mul(i)))
                //add chunk equal to 15% of sold tokens
                available.add(participants[msg.sender].sold.mul(15).div(100));

        // Limit to whole bonus bunch
        if (available > participants[msg.sender].bonus)
            available = participants[msg.sender].bonus;

        // Return value doesn't include claimed bonus
        return available.sub(participants[msg.sender].claimed);
    }
    
    // ------------------------------------------------------------------------
    // Get bonus amount still locked
    // ------------------------------------------------------------------------
    function getBonusLocked() public view returns(uint) {
        return getBonus() - getBonusAvailable() - getBonusClaimed();
    }

    // ------------------------------------------------------------------------
    // Get bonus amount already claimed by sender
    // ------------------------------------------------------------------------
    function getBonusClaimed() public view returns(uint) {
        return participants[msg.sender].claimed;
    }

    // ------------------------------------------------------------------------
    // Sends bonus
    // ------------------------------------------------------------------------
    function claimBonus(uint _value) public returns(bool) {
        require(getBonusAvailable() >= _value);
        participants[msg.sender].claimed = participants[msg.sender].claimed.add(_value);
        crowdsaleToken.transfer(msg.sender, _value);
    }

    // ------------------------------------------------------------------------
    // Update actual ETH price
    // ------------------------------------------------------------------------
    function updateEtherPrice(uint usd) public onlyManager {
        etherPrice = usd.mul(1 ether);
    }

    // ------------------------------------------------------------------------
    // Calculates actual token price in ETH
    // ------------------------------------------------------------------------
    function price() internal view returns (uint) {
        return basicPrice.div(etherPrice.div(1 ether));
    }

    // ------------------------------------------------------------------------
    // Withdraws ETH funds to the funding address upon successful crowdsale
    // ------------------------------------------------------------------------
    function withdraw(uint _value) public onlyOwner() hasntStopped() whenCrowdsaleSuccessful() {
        require(_value <= address(this).balance);
        fundingAddress.transfer(_value);
    }

    // ------------------------------------------------------------------------
    // Backers refund their ETH if the crowdsale has been cancelled or failed
    // ------------------------------------------------------------------------
    function refund() public {
        // Either cancelled or failed
        require(stopped || isFailed());

        uint amount = participants[msg.sender].funded;

        // Prevent from doing it twice
        require(amount > 0);
        participants[msg.sender].funded = 0;

        msg.sender.transfer(amount);
    }

    // ------------------------------------------------------------------------
    // WINGS integration
    // ------------------------------------------------------------------------
    function getToken() public returns(address) {
        return crowdsaleToken;
    }

    function deposit() public payable {
        revert();
    }

    function mintETHRewards(address, uint) public onlyManager {
        revert();
    }

    function mintTokenRewards(address forecasting, uint tokens) public onlyManager
    {
        crowdsaleToken.give(forecasting, tokens);
    }

    function releaseTokens() public onlyManager hasntStopped whenCrowdsaleSuccessful
    {
        crowdsaleToken.release();
    }

}
