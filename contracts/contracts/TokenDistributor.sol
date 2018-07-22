pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Crowdsale.sol";
import "./WonoToken.sol";
import {l_Scenario} from "./Scenario.sol";

contract TokenDistributor is Ownable {
    using SafeMath for uint;

    Crowdsale crowdsale;
    WonoToken crowdsaleToken;

    enum Purpose {
        Owners,
        Others,
        Developers,
        Marketing,
        Business,
        Advisors,
        Bounty,
        Reserve
    }
    
    address[8] distributionAddress;
    
    struct Account {
        uint Amount;
        uint Claimed;
    }
    
    uint deliverTimestamp;
    
    Account[5][8] accounts;
    uint[5][8][5] scheme;
    
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor (address crowdsaleAddress) public {
        crowdsale = Crowdsale(crowdsaleAddress);
        crowdsaleToken = WonoToken(crowdsale.getToken());

        createScheme();
    }

    // ------------------------------------------------------------------------
    // Filling distribution scheme
    // ------------------------------------------------------------------------
    function createScheme() internal {
        //                                                                          ICO         12mnths     18mnths     24mnths     30mnths
        // SoftCap scenario                                                         
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Owners)     ] = [ 0.012E8,    0.020E8,    0.016E8,    0.016E8,    0.016E8 ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Others)     ] = [ 0.020E8,    0,          0,          0,          0       ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Developers) ] = [ 0.006E8,    0.010E8,    0.008E8,    0.008E8,    0.008E8 ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Marketing)  ] = [ 0.005E8,    0.008E8,    0.006E8,    0.006E8,    0.006E8 ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Business)   ] = [ 0.005E8,    0.008E8,    0.006E8,    0.006E8,    0.006E8 ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Advisors)   ] = [ 0.050E8,    0,          0,          0,          0       ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Bounty)     ] = [ 0.030E8,    0,          0,          0,          0       ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Reserve)    ] = [ 0,          0,          0,          0,          0       ];
        // Moderate scenario
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Owners)     ] = [ 0.012E8,    0.020E8,    0.016E8,    0.016E8,    0.016E8 ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Others)     ] = [ 0.020E8,    0,          0,          0,          0       ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Developers) ] = [ 0.006E8,    0.010E8,    0.008E8,    0.008E8,    0.008E8 ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Marketing)  ] = [ 0.005E8,    0.008E8,    0.006E8,    0.006E8,    0.006E8 ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Business)   ] = [ 0.005E8,    0.008E8,    0.006E8,    0.006E8,    0.006E8 ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Advisors)   ] = [ 0.050E8,    0,          0,          0,          0       ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Bounty)     ] = [ 0.030E8,    0,          0,          0,          0       ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Reserve)    ] = [ 0.040E8,    0,          0,          0,          0       ];
        // Average scenario
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Owners)     ] = [ 0.012E8,    0.020E8,    0.016E8,    0.016E8,    0.016E8 ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Others)     ] = [ 0.020E8,    0,          0,          0,          0       ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Developers) ] = [ 0.006E8,    0.010E8,    0.008E8,    0.008E8,    0.008E8 ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Marketing)  ] = [ 0.005E8,    0.008E8,    0.006E8,    0.006E8,    0.006E8 ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Business)   ] = [ 0.005E8,    0.008E8,    0.006E8,    0.006E8,    0.006E8 ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Advisors)   ] = [ 0.050E8,    0,          0,          0,          0       ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Bounty)     ] = [ 0.030E8,    0,          0,          0,          0       ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Reserve)    ] = [ 0.080E8,    0,          0,          0,          0       ];
        // HardCap scenario
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Owners)     ] = [ 0.012E8,    0.020E8,    0.016E8,    0.016E8,    0.016E8 ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Others)     ] = [ 0.020E8,    0,          0,          0,          0       ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Developers) ] = [ 0.006E8,    0.010E8,    0.008E8,    0.008E8,    0.008E8 ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Marketing)  ] = [ 0.005E8,    0.008E8,    0.006E8,    0.006E8,    0.006E8 ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Business)   ] = [ 0.005E8,    0.008E8,    0.006E8,    0.006E8,    0.006E8 ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Advisors)   ] = [ 0.050E8,    0,          0,          0,          0       ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Bounty)     ] = [ 0.030E8,    0,          0,          0,          0       ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Reserve)    ] = [ 0.120E8,    0,          0,          0,          0       ];
    }

    // ------------------------------------------------------------------------
    // Distributing tokens
    // ------------------------------------------------------------------------
    function distribute() public {
        l_Scenario.Scenario scenario = crowdsale.scenario();
        uint totalSold = crowdsale.getTotalSold();
        for (uint8 purpose = 0; purpose < 8; purpose++)
            for (uint8 period = 0; period < 5; period++)
                accounts[purpose][period].Amount = scheme[uint8(scenario)][purpose][period].mul(totalSold).div(1E8);
    }
    
    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }

    // ------------------------------------------------------------------------
    // Get period
    // ------------------------------------------------------------------------
    function getPeriod() public view returns(uint8) {
        if (deliverTimestamp > 0 && block.timestamp >= deliverTimestamp + 182 * 5 * 86400)      // approx. 30 months after delivery
            return 4;
        else if (deliverTimestamp > 0 && block.timestamp >= deliverTimestamp + 182 * 4 * 86400) // approx. 24 months after delivery
            return 3;
        else if (deliverTimestamp > 0 && block.timestamp >= deliverTimestamp + 182 * 3 * 86400) // approx. 18 months after delivery
            return 2;
        else if (deliverTimestamp > 0 && block.timestamp >= deliverTimestamp + 182 * 2 * 86400) // approx. 12 months after delivery
            return 1;
        else    // before delivery
            return 0;
    }
    
    // ------------------------------------------------------------------------
    // Call on Proof-of-Concept delivered
    // ------------------------------------------------------------------------
    function PoCDelivered() public onlyOwner {
        require(deliverTimestamp == 0);
        deliverTimestamp = block.timestamp;
    }
        
    // ------------------------------------------------------------------------
    // Address setters
    // ------------------------------------------------------------------------
    function setDistributionAddress(Purpose purpose, address a) public onlyOwner() {
        distributionAddress[uint8(purpose)] = a;
    }

    // ------------------------------------------------------------------------
    // Returns amount distributed
    // ------------------------------------------------------------------------
    function getTokensTotal(Purpose purpose) public view returns (uint) {
        return accounts[uint8(purpose)][0].Amount
                .add(accounts[uint8(purpose)][1].Amount)
                .add(accounts[uint8(purpose)][2].Amount)
                .add(accounts[uint8(purpose)][3].Amount)
                .add(accounts[uint8(purpose)][4].Amount);
    }
    
    // ------------------------------------------------------------------------
    // Returns amount claimed
    // ------------------------------------------------------------------------
    function getTokensClaimed(Purpose purpose) public view returns (uint) {
        return accounts[uint8(purpose)][0].Claimed
                .add(accounts[uint8(purpose)][1].Claimed)
                .add(accounts[uint8(purpose)][2].Claimed)
                .add(accounts[uint8(purpose)][3].Claimed)
                .add(accounts[uint8(purpose)][4].Claimed);
    }
    
    // ------------------------------------------------------------------------
    // Returns amount available to withdrawal
    // ------------------------------------------------------------------------
    function getTokensAvailable(Purpose purpose) public view returns (uint) {
        uint8 currentPeriod = getPeriod();
        Account memory account;
        for (uint8 period = 0; period < 5; period++) {
            if (period <= currentPeriod)
                account.Amount = account.Amount.add(accounts[uint8(purpose)][period].Amount);
            account.Claimed = account.Claimed.add(accounts[uint8(purpose)][period].Claimed);
        }
        return account.Amount.sub(account.Claimed);
    }
    
    // ------------------------------------------------------------------------
    // Winthdrawals
    // ------------------------------------------------------------------------
    function withdraw(Purpose purpose, uint amount) public {
        require(distributionAddress[uint8(purpose)] != 0x0);
        uint8 currentPeriod = getPeriod();
        uint yetToSend = amount;
        uint amountToSend;
        for (uint8 period = 0; period <= currentPeriod && yetToSend > 0; period++) {
            uint available = accounts[uint8(purpose)][period].Amount.sub(accounts[uint8(purpose)][period].Claimed);
            uint chunk;
            if (available >= yetToSend)
                chunk = yetToSend;
            else
                chunk = available;
            accounts[uint8(purpose)][period].Claimed = accounts[uint8(purpose)][period].Claimed.add(chunk);
            yetToSend = yetToSend.sub(chunk);
            amountToSend = amountToSend.add(chunk);
        }
        crowdsaleToken.transfer(distributionAddress[uint8(purpose)], amountToSend);
    }  
}
