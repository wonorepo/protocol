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
    
    address[8] public distributionAddress;
    
    struct Account {
        uint Amount;
        uint Claimed;
    }
    
    Account[8] public accounts;
    uint[8][5] public scheme;
    
    event DISTRIBUTED(uint8 scenario, uint8 purpose, uint amount);
    
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
        // SoftCap scenario                                                         
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Owners)     ] = 0.06E8;
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Others)     ] = 0.04E8;
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Developers) ] = 0.04E8;
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Marketing)  ] = 0.03E8;
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Business)   ] = 0.03E8;
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Advisors)   ] = 0.05E8;
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Bounty)     ] = 0.03E8;
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Reserve)    ] = 0;
        // Moderate scenario
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Owners)     ] = 0.06E8;
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Others)     ] = 0.04E8;
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Developers) ] = 0.04E8;
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Marketing)  ] = 0.03E8;
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Business)   ] = 0.03E8;
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Advisors)   ] = 0.05E8;
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Bounty)     ] = 0.03E8;
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Reserve)    ] = 0.04E8;
        // Average scenario
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Owners)     ] = 0.06E8;
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Others)     ] = 0.04E8;
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Developers) ] = 0.04E8;
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Marketing)  ] = 0.03E8;
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Business)   ] = 0.03E8;
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Advisors)   ] = 0.05E8;
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Bounty)     ] = 0.03E8;
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Reserve)    ] = 0.08E8;
        // HardCap scenario
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Owners)     ] = 0.06E8;
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Others)     ] = 0.04E8;
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Developers) ] = 0.04E8;
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Marketing)  ] = 0.03E8;
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Business)   ] = 0.03E8;
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Advisors)   ] = 0.05E8;
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Bounty)     ] = 0.03E8;
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Reserve)    ] = 0.12E8;
    }

    // ------------------------------------------------------------------------
    // Distributing tokens
    // ------------------------------------------------------------------------
    function distribute() public {
        l_Scenario.Scenario scenario = crowdsale.scenario();
        uint totalSold = crowdsale.getTotalSold();
        for (uint8 purpose = 0; purpose < 8; purpose++) {
            accounts[purpose].Amount = scheme[uint8(scenario)][purpose].mul(totalSold).div(1E8);
            emit DISTRIBUTED(uint8(scenario), purpose, accounts[purpose].Amount);
        }
    }
    
    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
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
        return accounts[uint8(purpose)].Amount;
    }
    
    // ------------------------------------------------------------------------
    // Returns amount claimed
    // ------------------------------------------------------------------------
    function getTokensClaimed(Purpose purpose) public view returns (uint) {
        return accounts[uint8(purpose)].Claimed;
    }
    
    // ------------------------------------------------------------------------
    // Returns amount available to withdrawal
    // ------------------------------------------------------------------------
    function getTokensAvailable(Purpose purpose) public view returns (uint) {
        return accounts[uint8(purpose)].Amount.sub(accounts[uint8(purpose)].Claimed);
    }
    
    // ------------------------------------------------------------------------
    // Winthdrawals
    // ------------------------------------------------------------------------
    function withdraw(Purpose purpose, uint tokens) public {
        require(distributionAddress[uint8(purpose)] != 0x0);
        require(tokens <= accounts[uint8(purpose)].Amount.sub(accounts[uint8(purpose)].Claimed));
        accounts[uint8(purpose)].Claimed.add(tokens);
        crowdsaleToken.transfer(distributionAddress[uint8(purpose)], tokens);
    }  
}
