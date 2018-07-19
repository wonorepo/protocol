pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Crowdsale.sol";
import {l_Scenario} from "./Scenario.sol";

contract EtherDistributor is Ownable {
    using SafeMath for uint;

    Crowdsale crowdsale;

    bool full;
    
    enum Purpose {
        Engineering,
        Marketing,
        Business,
        Legal,
        Community,
        Advisors
    }
      
    address[5] distributionAddress;
    
    struct Account {
        uint Amount;
        uint Claimed;
    }
    
    Account[3][6] accounts;
    uint[3][6][5] scheme;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor (address crowdsaleAddress) public {
        crowdsale = Crowdsale(crowdsaleAddress);
        full = false;

        createScheme();
    }
    
    // ------------------------------------------------------------------------
    // Filling distribution scheme
    // ------------------------------------------------------------------------
    function createScheme() internal {
        //                                                                          2018            2019            2020
        // SoftCap scenario                                                         
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Engineering)] = [ 0.2200000E8,    0.2750000E8,    0.0550000E8  ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Marketing)  ] = [ 0.0314250E8,    0.1011750E8,    0.0174000E8  ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Business)   ] = [ 0.0400000E8,    0.0400000E8,    0.0200000E8  ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Legal)      ] = [ 0.0750000E8,    0.0450000E8,    0.0300000E8  ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Community)  ] = [ 0.0200000E8,    0.0200000E8,    0.0100000E8  ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Advisors)   ] = [ 0,              0,              0            ];
        // Moderate scenario
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Engineering)] = [ 0.2000000E8,    0.2250000E8,    0.0750000E8  ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Marketing)  ] = [ 0.0460900E8,    0.1483900E8,    0.0255200E8  ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Business)   ] = [ 0.0400000E8,    0.0400000E8,    0.0200000E8  ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Legal)      ] = [ 0.0650000E8,    0.0390000E8,    0.0260000E8  ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Community)  ] = [ 0.0200000E8,    0.0200000E8,    0.0100000E8  ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Advisors)   ] = [ 0,              0,              0            ];
        // Average scenario
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Engineering)] = [ 0.1575000E8,    0.2025000E8,    0.0900000E8  ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Marketing)  ] = [ 0.0527500E8,    0.1682500E8,    0.0290000E8  ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Business)   ] = [ 0.0400000E8,    0.0400000E8,    0.0200000E8  ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Legal)      ] = [ 0.0500000E8,    0.0300000E8,    0.0200000E8  ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Community)  ] = [ 0.0400000E8,    0.0400000E8,    0.0200000E8  ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Advisors)   ] = [ 0,              0,              0            ];
        // HardCap scenario
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Engineering)] = [ 0.1200000E8,    0.1600000E8,    0.1200000E8  ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Marketing)  ] = [ 0.0637125E8,    0.2014875E8,    0.0348000E8  ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Business)   ] = [ 0.0400000E8,    0.0400000E8,    0.0200000E8  ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Legal)      ] = [ 0.0500000E8,    0.0300000E8,    0.0200000E8  ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Community)  ] = [ 0.0400000E8,    0.0400000E8,    0.0200000E8  ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Advisors)   ] = [ 0,              0,              0            ];
    }
    
    // ------------------------------------------------------------------------
    // Distributing Ether
    // ------------------------------------------------------------------------
    function distribute() internal {
        l_Scenario.Scenario scenario = crowdsale.scenario();
        for (uint8 purpose = 0; purpose < 5; ++purpose)
            for (uint8 period = 0; period < 3; ++period)
                accounts[purpose][period].Amount = scheme[uint8(scenario)][purpose][period].mul(crowdsale.totalCollected()).div(1E8);
    }
      
    // ------------------------------------------------------------------------
    // Accept ETH from crowdsale contract
    // ------------------------------------------------------------------------
    function () public payable {
        require(msg.sender == address(crowdsale));
        full = true;
        distribute();
    }
    
    // ------------------------------------------------------------------------
    // Get period
    // ------------------------------------------------------------------------
    function getPeriod() public view returns(uint8) {
        if (block.timestamp >= 1577836800) // 2020-01-01T00:00:00Z
            return 2;
        else if (block.timestamp >= 1546300800) // 2019-01-01T00:00:00Z
            return 1;
        else // 2018-01-01T00:00:00Z
            return 0;
    }

    // ------------------------------------------------------------------------
    // Sets withdrawal address for specified purpose
    // ------------------------------------------------------------------------
    function setDistributionAddress(Purpose purpose, address a) public onlyOwner() {
        distributionAddress[uint8(purpose)] = a;
    }

    // ------------------------------------------------------------------------
    // Withdraws funds for specified purpose
    // ------------------------------------------------------------------------
    function withdraw(Purpose purpose, uint amount) public onlyOwner() {
        require(distributionAddress[uint8(purpose)] != 0x0);
        uint8 currentPeriod = getPeriod();
        Account memory account;
        for (uint8 period = 0; period <= currentPeriod; ++period) {
            account.Amount.add(accounts[uint8(purpose)][period].Amount);
            account.Claimed.add(accounts[uint8(purpose)][period].Claimed);
            uint chunk = account.Amount.sub(account.Claimed);
            if (amount <= chunk) {
                amount.sub(chunk);
                accounts[uint8(purpose)][period].Claimed.add(chunk);
                account.Claimed.add(chunk);
                distributionAddress[uint8(purpose)].transfer(chunk);
            }
        }
    }
    
    // ------------------------------------------------------------------------
    // Returns amount available to withdrawal for specified purpose now
    // ------------------------------------------------------------------------
    function getAvailable(Purpose purpose) public view returns(uint) {
        uint8 currentPeriod = getPeriod();
        Account memory account;
        for (uint8 period = 0; period <= currentPeriod; ++period) {
            account.Amount.add(accounts[uint8(purpose)][period].Amount);
            account.Claimed.add(accounts[uint8(purpose)][period].Claimed);
        }
        return account.Amount.sub(account.Claimed);
    }
}