pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Crowdsale.sol";
import {l_Scenario} from "./Scenario.sol";

contract EtherDistributor is Ownable {
    using SafeMath for uint;

    Crowdsale crowdsale;

    enum Purpose {
        Engineering,
        Marketing,
        Business,
        Legal,
        Community,
        Others
    }
      
    address[6] distributionAddress;
    
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

        createScheme();
    }
    
    // ------------------------------------------------------------------------
    // Filling distribution scheme
    // ------------------------------------------------------------------------
    function createScheme() internal {
        //                                                                          2018            2019            2020
        // SoftCap scenario                                                         
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Engineering)] = [ 0.1800000E8,    0.2750000E8,    0.0550000E8  ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Marketing)  ] = [ 0.0314250E8,    0.1011750E8,    0.0174000E8  ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Business)   ] = [ 0.0400000E8,    0.0400000E8,    0.0200000E8  ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Legal)      ] = [ 0.0750000E8,    0.0450000E8,    0.0300000E8  ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Community)  ] = [ 0.0200000E8,    0.0200000E8,    0.0100000E8  ];
        scheme[uint8(l_Scenario.Scenario.SoftCap) ][uint8(Purpose.Others)     ] = [ 0.0400000E8,    0,              0            ];
        // Moderate scenario
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Engineering)] = [ 0.1600000E8,    0.2250000E8,    0.0750000E8  ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Marketing)  ] = [ 0.0460900E8,    0.1483900E8,    0.0255200E8  ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Business)   ] = [ 0.0400000E8,    0.0400000E8,    0.0200000E8  ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Legal)      ] = [ 0.0650000E8,    0.0390000E8,    0.0260000E8  ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Community)  ] = [ 0.0200000E8,    0.0200000E8,    0.0100000E8  ];
        scheme[uint8(l_Scenario.Scenario.Moderate)][uint8(Purpose.Others)     ] = [ 0.0400000E8,    0,              0            ];
        // Average scenario
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Engineering)] = [ 0.1175000E8,    0.2025000E8,    0.0900000E8  ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Marketing)  ] = [ 0.0527500E8,    0.1682500E8,    0.0290000E8  ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Business)   ] = [ 0.0400000E8,    0.0400000E8,    0.0200000E8  ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Legal)      ] = [ 0.0500000E8,    0.0300000E8,    0.0200000E8  ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Community)  ] = [ 0.0400000E8,    0.0400000E8,    0.0200000E8  ];
        scheme[uint8(l_Scenario.Scenario.Average) ][uint8(Purpose.Others)     ] = [ 0.0400000E8,    0,              0            ];
        // HardCap scenario
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Engineering)] = [ 0.0800000E8,    0.1600000E8,    0.1200000E8  ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Marketing)  ] = [ 0.0637125E8,    0.2014875E8,    0.0348000E8  ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Business)   ] = [ 0.0400000E8,    0.0400000E8,    0.0200000E8  ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Legal)      ] = [ 0.0500000E8,    0.0300000E8,    0.0200000E8  ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Community)  ] = [ 0.0400000E8,    0.0400000E8,    0.0200000E8  ];
        scheme[uint8(l_Scenario.Scenario.HardCap) ][uint8(Purpose.Others)     ] = [ 0.0400000E8,    0,              0            ];
    }
    
    // ------------------------------------------------------------------------
    // Distributing Ether
    // ------------------------------------------------------------------------
    function distribute() public onlyOwner {
        l_Scenario.Scenario scenario = crowdsale.scenario();
        uint totalCollectedEth = crowdsale.getTotalCollectedEth().sub(crowdsale.getSAFTEth());
        for (uint8 purpose = 0; purpose < 6; ++purpose)
            for (uint8 period = 0; period < 3; ++period)
                accounts[purpose][period].Amount = scheme[uint8(scenario)][purpose][period].mul(totalCollectedEth).div(1E8);
    }
      
    // ------------------------------------------------------------------------
    // Accept ETH from crowdsale contract
    // ------------------------------------------------------------------------
    function () public payable {
        require(msg.sender == address(crowdsale));
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
    // Returns amount distributed
    // ------------------------------------------------------------------------
    function getEtherTotal(Purpose purpose) public view returns (uint) {
        return accounts[uint8(purpose)][0].Amount
                .add(accounts[uint8(purpose)][1].Amount)
                .add(accounts[uint8(purpose)][2].Amount);
    }
    
    // ------------------------------------------------------------------------
    // Returns amount claimed
    // ------------------------------------------------------------------------
    function getEtherClaimed(Purpose purpose) public view returns (uint) {
        return accounts[uint8(purpose)][0].Claimed
                .add(accounts[uint8(purpose)][1].Claimed)
                .add(accounts[uint8(purpose)][2].Claimed);
    }
    
    // ------------------------------------------------------------------------
    // Returns amount available to withdrawal
    // ------------------------------------------------------------------------
    function getEtherAvailable(Purpose purpose) public view returns (uint) {
        uint8 currentPeriod = getPeriod();
        Account memory account;
        for (uint8 period = 0; period < 3; period++) {
            if (period <= currentPeriod)
                account.Amount = account.Amount.add(accounts[uint8(purpose)][period].Amount);
            account.Claimed = account.Claimed.add(accounts[uint8(purpose)][period].Claimed);
        }
        return account.Amount.sub(account.Claimed);
    }

    // ------------------------------------------------------------------------
    // Withdraws funds for specified purpose
    // ------------------------------------------------------------------------
    function withdraw(Purpose purpose, uint amount) public onlyOwner() {
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
        distributionAddress[uint8(purpose)].transfer(amountToSend);
    }
}
