pragma solidity ^0.4.23;

import "./Crowdsale.sol";

contract BonusMeter {
    Crowdsale public crowdsale;
    
    constructor (address crowdsaleAddress) public {
        crowdsale = Crowdsale(crowdsaleAddress);
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }

    function getBonusPercent () public view returns (uint) {
        uint totalCollected = crowdsale.totalCollected();
        
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
