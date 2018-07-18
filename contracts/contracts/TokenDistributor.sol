pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Crowdsale.sol";
import "./WonoToken.sol";
import {l_Scenario} from "./Scenario.sol";

contract EtherDistributor is Ownable {
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
    
    address[4] distributionAddress;
    
    struct Account {
        uint Amount;
        uint Claimed;
    }
    
    Account[8] accounts;
    uint[5][8] scheme;
    
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor (address crowdsaleAddress) public {
        crowdsale = Crowdsale(crowdsaleAddress);
        crowdsaleToken = WonoToken(crowdsale.getToken());
    }

    // ------------------------------------------------------------------------
    // Filling distribution scheme
    // ------------------------------------------------------------------------
    function createScheme() internal {
        // SoftCap scenario                                                         
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Owners)     ] = 0.06E18;
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Others)     ] = 0.04E18;
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Developers) ] = 0.04E18;
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Marketing)  ] = 0.03E18;
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Business)   ] = 0.03E18;
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Advisors)   ] = 0.05E18;
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Bounty)     ] = 0.03E18;
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Reserve)    ] = 0;
        // Moderate scenario
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Owners)     ] = 0.06E18;
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Others)     ] = 0.04E18;
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Developers) ] = 0.04E18;
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Marketing)  ] = 0.03E18;
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Business)   ] = 0.03E18;
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Advisors)   ] = 0.05E18;
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Bounty)     ] = 0.03E18;
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Reserve)    ] = 0.04E18;
        // Average scenario
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Owners)     ] = 0.06E18;
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Others)     ] = 0.04E18;
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Developers) ] = 0.04E18;
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Marketing)  ] = 0.03E18;
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Business)   ] = 0.03E18;
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Advisors)   ] = 0.05E18;
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Bounty)     ] = 0.03E18;
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Reserve)    ] = 0.08E18;
        // HardCap scenario
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Owners)     ] = 0.06E18;
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Others)     ] = 0.04E18;
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Developers) ] = 0.04E18;
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Marketing)  ] = 0.03E18;
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Business)   ] = 0.03E18;
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Advisors)   ] = 0.05E18;
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Bounty)     ] = 0.03E18;
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Reserve)    ] = 0.12E18;
    }

    // ------------------------------------------------------------------------
    // Distributing tokens
    // ------------------------------------------------------------------------
    function distribute() public onlyOwner() {
        l_Scenario.Scenario scenario = crowdsale.scenario();
        for (uint8 purpose = 0; purpose < 8; ++purpose)
            accounts[purpose].Amount = scheme[uint8(scenario)][purpose].mul(crowdsale.totalSold()).div(1E18);
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
    // Winthdrawals
    // ------------------------------------------------------------------------
    function withdraw(Purpose purpose, uint tokens) public onlyOwner() {
        require(tokens <= accounts[uint8(purpose)].Amount.sub(accounts[uint8(purpose)].Claimed));
        accounts[uint8(purpose)].Claimed.add(tokens);
        crowdsaleToken.transfer(distributionAddress[uint8(purpose)], tokens);
    }  
}
