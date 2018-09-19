pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
//import "../../externals/wings-integration/contracts/interfaces/ICrowdsaleProcessor.sol";
import "./WonoToken.sol";
import "./Whitelist.sol";
import {l_Scenario} from "./Scenario.sol";

contract Crowdsale is Ownable {
    using SafeMath for uint;

    address public manager;
    
    WonoToken public crowdsaleToken;
    Whitelist public whitelist;
    
    bool public started;
    bool public stopped;
    
    uint public startTimestamp;
    uint public endTimestamp;
    
    address etherDistributionAddress;
    address tokenDistributionAddress;
    
    uint public hardCap;
    uint public softCap;
    
    uint public totalSold;
    uint public totalCollected;
    uint public totalCollectedEth;
    uint public saftEth;

    uint public basicPrice;
    uint public etherPrice;

    l_Scenario.Scenario public scenario;

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

    mapping(address => Participant) public participants; // list of participants

    // ========================================================================
    // Events
    // ========================================================================
    
    event CROWDSALE_START(uint startTimestamp, uint endTimestamp);
    event CROWDSALE_STOP();
    event CROWDSALE_FUND(address indexed backer, uint ethReceived, uint ethPrice);
    event CROWDSALE_CHUNK(address indexed backer, uint chunSize, uint ethPrice);
    event CROWDSALE_SAFT(address indexed backer, uint usdReceived);
    event CROWDSALE_ETHER_PRICE(uint price);
    event CROWDSALE_BONUS_GIVEN(address indexed backer, uint tokens, uint bonus);
    event CROWDSALE_BONUS_CLAIMED(address indexed backer, uint amount);
    
    // ========================================================================
    // Modifiers
    // ========================================================================
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }
    
    modifier onlyStaff() {
        require(
            msg.sender == manager
            || msg.sender == owner
        );
        _;
    }
    
    modifier isStarted() {
        require(started);
        _;
    }
    
    modifier isStopped() {
        require(stopped);
        _;
    }

    modifier notStarted() {
        require(!started);
        _;
    }

    
    modifier notStopped() {
        require(!stopped);
        _;
    }
    
    modifier crowdsaleActive() {
        require(isActive());
        _;
    }
    
    modifier crowdsaleFailed() {
        require(isFailed());
        _;
    }

    modifier crowdsaleSuccessful() {
        require(isSuccessful());
        _;
    }

    
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor (address _tokenAddress, address _whitelistAddress) public {
        basicPrice = 0.5 ether;         // NOTE: Actually is USD
        softCap = 6000000 ether;        // NOTE: Actually in USD
        hardCap = 21000000 ether;       // NOTE: Actually in USD
        etherPrice = 1000 ether;        // NOTE: Actually in USD
        totalCollected = 0;             // NOTE: Actually in USD
        totalCollectedEth = 0;
        totalSold = 0;
        saftEth = 0;
        
        started = false;
        stopped = false;

        crowdsaleToken = WonoToken(_tokenAddress);
        whitelist = Whitelist(_whitelistAddress);
    }

    // ========================================================================
    // Various getters
    // ========================================================================
    
    function isActive() public view returns (bool) {
        return (
            started
            && totalCollected < hardCap
            && block.timestamp >= startTimestamp
            && block.timestamp < endTimestamp
        );
    }

    function isSuccessful() public view returns (bool) {
        return (
            totalCollected >= hardCap
            || (
                block.timestamp >= endTimestamp
                && totalCollected >= softCap
            )
        );
    }
    
    function isFailed() public view returns (bool) {
        return (
            started
            && block.timestamp >= endTimestamp
            && totalCollected < softCap
        );
    }

    function getWhitelist() public view returns(address) {
        return whitelist;
    }
    
    function getToken() public view returns(address) {
        return crowdsaleToken;
    }

    // ========================================================================
    // Crowdsale control
    // ========================================================================

    // ------------------------------------------------------------------------
    // Starts crowdsale
    // ------------------------------------------------------------------------
    function start(uint _start, uint _end) public onlyOwner() notStarted() notStopped() {
        require(block.timestamp <= _start);
        require(_end > _start);

        startTimestamp = _start;
        endTimestamp   = _end;
        started        = true;
        
        emit CROWDSALE_START(startTimestamp, endTimestamp);
    }
    
    
    // ------------------------------------------------------------------------
    // Sets token distribution adddress
    // ------------------------------------------------------------------------
    function setTokenDistributionAddress(address a) public onlyOwner() notStopped() {
        tokenDistributionAddress = a;
    }

    // ------------------------------------------------------------------------
    // Sets ether distribution adddress
    // ------------------------------------------------------------------------
    function setEtherDistributionAddress(address a) public onlyOwner() notStopped() {
        etherDistributionAddress = a;
    }
    
    // ------------------------------------------------------------------------
    // Sets crowdsale end timestamp
    // ------------------------------------------------------------------------
    function setEndTimestamp(uint timestamp) public onlyStaff() notStopped() {
        endTimestamp = timestamp;
    }
    
    // ========================================================================
    // Emergency procedures
    // ========================================================================

    // ------------------------------------------------------------------------
    // Cancel crowdsale
    // ------------------------------------------------------------------------
    function stop() public onlyOwner() notStopped()  {
        if (started) {
            require(!isFailed());
            require(!isSuccessful());
        }
        stopped = true;
        
        emit CROWDSALE_STOP();
    }
    
    function close() public onlyOwner() isStopped() {
        require(crowdsaleToken.owner() == owner);
        selfdestruct(owner);
    }
    
    function returnOwnership() public onlyOwner() {
        crowdsaleToken.transferOwnership(owner);
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
    
    // ========================================================================
    // Token sale and burning
    // ========================================================================

    // ------------------------------------------------------------------------
    // Accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        require(msg.value > 0);
        sell(msg.sender, msg.value, etherPrice);
        totalCollectedEth = totalCollectedEth.add(msg.value);
        emit CROWDSALE_FUND(msg.sender, msg.value, etherPrice);
    }
    
    // ------------------------------------------------------------------------
    // Register SAFT
    // ------------------------------------------------------------------------
    function registerSAFT(address _recipient, uint _value, uint _etherPrice) public onlyStaff() {
        sell(_recipient, _value, _etherPrice);
        saftEth = saftEth.add(_value);
        emit CROWDSALE_SAFT(_recipient, _value);
    }
    
    // ------------------------------------------------------------------------
    // Token distribution method
    // ------------------------------------------------------------------------
    function sell(address _recipient, uint _value, uint _etherPrice) internal isStarted() notStopped() crowdsaleActive() returns (uint) {
        require(whitelist.isApproved(_recipient));

        uint collected = _value.mul(_etherPrice.div(1e9)).div(1e9);   // Collected in USD

        // Calculate change in case of hitting hard cap
        if (hardCap < totalCollected.add(collected)) {
            // Calculate change
            uint change = (collected.add(totalCollected).sub(hardCap)).div(_etherPrice.div(1e9)).mul(1e9); // Change in ETH

            // Give change back
            _recipient.transfer(change);
            _value = _value.sub(change);    // Reduce _value by change
            collected = _value.mul(_etherPrice.div(1e9)).div(1e9);   // Recalculate collected in USD in case of change
        }

        // Check if beyond single price range
        uint leftToSell;
        for (uint8 i = 0; i < 5 && leftToSell == 0; ++i) {  // Stop iterating if any single price range boundary hit
            if (totalCollected < priceRange[i] && priceRange[i] <= totalCollected.add(collected)) {
                uint chunk = (priceRange[i].sub(totalCollected)).mul(1e9).div(_etherPrice.div(1e9));  // Chunk in ETH
                if (chunk == 0) { // Wiping dust
                    totalCollected = priceRange[i];
                }
                leftToSell = _value.sub(chunk);
                _value = chunk;
                collected = _value.mul(_etherPrice.div(1e9)).div(1e9);   // Recalculate collected in USD in case of chunking
                emit CROWDSALE_CHUNK(_recipient, chunk, _etherPrice);
            }
        }

        // Sell tokens with current price
        uint tokens = _value.mul(1e18).div(price());
        participants[_recipient].sold = participants[_recipient].sold.add(tokens);
        crowdsaleToken.give(_recipient, tokens);

        // Give bonus
        uint bonusTokens = 0;
        for (i = 0; i < 5 && bonusTokens == 0; ++i) {
            if (totalCollected.add(collected) <= priceRange[i]) {
                bonusTokens = tokens.mul(bonus[i]).div(100);
            }
        }
        if (bonusTokens > 0) {
            participants[_recipient].bonus = participants[_recipient].bonus.add(bonusTokens);
            crowdsaleToken.give(address(this), bonusTokens);
            emit CROWDSALE_BONUS_GIVEN(_recipient, tokens, bonusTokens);
        }

        // Update counters
        totalCollected = totalCollected.add(collected);
        participants[_recipient].funded = participants[_recipient].funded.add(_value);
        totalSold = totalSold.add(tokens).add(bonusTokens);
        
        // Update token distribution scenario
        updateScenario();

        // Sell rest amount with another price
        if (leftToSell > 0) {
            log1(0xDEADBEEF, bytes32(leftToSell));
            return _value.add(sell(_recipient, leftToSell, _etherPrice));
        }
        else {
            log1(0xBABECAFE, bytes32(leftToSell));
            return _value.add(leftToSell);
        }
    }
    
    // ------------------------------------------------------------------------
    // Burn undistributed tokens
    // ------------------------------------------------------------------------
    function sterilize() public onlyStaff() {
        crowdsaleToken.sterilize();
    }

    // ------------------------------------------------------------------------
    // Releases tokens after crowdsale
    // ------------------------------------------------------------------------
    function releaseTokens() public onlyStaff() notStopped() crowdsaleSuccessful() {
        crowdsaleToken.release();
    }

    // ========================================================================
    // Token sale progress getters
    // ========================================================================

    // ------------------------------------------------------------------------
    // Get total amount of tokens sold
    // ------------------------------------------------------------------------
    function getTotalSold() public view returns(uint) {
        return totalSold;
    }
    
    // ------------------------------------------------------------------------
    // Get total amount of ether collected
    // ------------------------------------------------------------------------
    function getTotalCollectedEth() public view returns(uint) {
        return totalCollectedEth;
    }
    
    // ------------------------------------------------------------------------
    // Get ether eqivalent of SAFT
    // ------------------------------------------------------------------------
    function getSAFTEth() public view returns(uint) {
        return saftEth;
    }

    // ========================================================================
    // Bonus getters
    // ========================================================================
    
    // ------------------------------------------------------------------------
    // Get tokens bought by address
    // ------------------------------------------------------------------------
    function getBought(address a) public view returns(uint) {
        return participants[a].sold;
    }

    // ------------------------------------------------------------------------
    // Get bonus amount for address
    // ------------------------------------------------------------------------
    function getBonus(address a) public view returns(uint) {
        return participants[a].bonus;
    }

    // ------------------------------------------------------------------------
    // Get bonus amount available to withdrawal for address
    // ------------------------------------------------------------------------
    function getBonusAvailable(address a) public view returns(uint) {
        uint available = 0;
        for (uint8 i = 0; i < 5; ++i)
            // Each 60 days
            if (block.timestamp >= endTimestamp.add(uint(86400).mul(60).mul(i)))
                //add chunk equal to 15% of sold tokens
                available = available.add(participants[a].sold.mul(15).div(100));

        // Limit to whole bonus bunch
        if (available > participants[a].bonus)
            available = participants[a].bonus;

        // Return value doesn't include claimed bonus
        return available.sub(participants[a].claimed);
    }
    
    // ------------------------------------------------------------------------
    // Get bonus amount still locked for address
    // ------------------------------------------------------------------------
    function getBonusLocked(address a) public view returns(uint) {
        return getBonus(a).sub(getBonusAvailable(a)).sub(getBonusClaimed(a));
    }

    // ------------------------------------------------------------------------
    // Get bonus amount already claimed by address
    // ------------------------------------------------------------------------
    function getBonusClaimed(address a) public view returns(uint) {
        return participants[a].claimed;
    }

    // ========================================================================
    // Bonus withdrawals
    // ========================================================================
    
    // ------------------------------------------------------------------------
    // Sends bonus
    // ------------------------------------------------------------------------
    function claimBonus(uint _value) public {
        require(getBonusAvailable(msg.sender) >= _value);
        participants[msg.sender].claimed = participants[msg.sender].claimed.add(_value);
        crowdsaleToken.transfer(msg.sender, _value);
        emit CROWDSALE_BONUS_CLAIMED(msg.sender, _value);
    }

    // ========================================================================
    // Price calculations
    // ========================================================================

    // ------------------------------------------------------------------------
    // Update actual ETH price
    // ------------------------------------------------------------------------
    function updateEtherPrice(uint usd) public onlyStaff() {
        etherPrice = usd; // Actually USD * 1E+18
        emit CROWDSALE_ETHER_PRICE(etherPrice);
    }
    
    // ------------------------------------------------------------------------
    // Calculates actual token price in ETH
    // ------------------------------------------------------------------------
    function price() internal view returns (uint) {
        return basicPrice.mul(1 ether).div(etherPrice);
    }

    // ========================================================================
    // Fund withdrawals
    // ========================================================================

    // ------------------------------------------------------------------------
    // Withdraws ETH funds to the funding address upon successful crowdsale
    // ------------------------------------------------------------------------
    function withdraw() public onlyStaff() notStopped() crowdsaleSuccessful() {
        etherDistributionAddress.transfer(address(this).balance);
    }
    
    // ------------------------------------------------------------------------
    // Withdraw tokens for distribution
    // ------------------------------------------------------------------------
    function withdrawTokens() public onlyStaff() notStopped() crowdsaleSuccessful() {
        require(tokenDistributionAddress != 0x0);
        
        // Checking scenario
        uint tokens;
        if (scenario == l_Scenario.Scenario.SoftCap)
            // See WP section 5.3
            tokens = totalSold.div(72).mul(28);
        else if (scenario == l_Scenario.Scenario.Moderate)
            // See WP section 5.3
            tokens = totalSold.div(68).mul(32);
        else if (scenario == l_Scenario.Scenario.Average)
            // See WP section 5.3
            tokens = totalSold.div(64).mul(36);
        else if (scenario == l_Scenario.Scenario.HardCap)
            // See WP section 5.2
            tokens = totalSold.div(60).mul(40);
        else
            // We've screwed up. Noone gets tokens. :(
            tokens = 0;
            
        // Passing tokens for distribution
        crowdsaleToken.give(tokenDistributionAddress, tokens);
    }

    // ========================================================================
    // Various state updaters/reporters
    // ========================================================================  
    
    // ------------------------------------------------------------------------
    // Updates token distribution scenario
    // ------------------------------------------------------------------------
    function updateScenario() internal {
        if (totalCollected >= 21E24)
            scenario = l_Scenario.Scenario.HardCap;
        else if (totalCollected >= 16E24)
            scenario = l_Scenario.Scenario.Average;
        else if (totalCollected >= 11E24)
            scenario = l_Scenario.Scenario.Moderate;
        else if (totalCollected >= 6E24)
            scenario = l_Scenario.Scenario.SoftCap;
        else
            scenario = l_Scenario.Scenario.ScrewUp;
    }
        
    // ------------------------------------------------------------------------
    // Returns current bonus percent
    // ------------------------------------------------------------------------
    function getBonusPercent () public view returns (uint) {
        if (totalCollected <= 1e24) {
            return 70;
        }
        else if (totalCollected <= 4e24) {
            return 30;
        }
        else if (totalCollected <= 8e24) {
            return 25;
        }
        else if (totalCollected <= 9e24) {
            return 10;
        }
        else if (totalCollected <= 10e14) {
            return 5;
        }
        return 0;
    }
}
