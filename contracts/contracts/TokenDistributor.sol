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

    address[4] distributionAddress;
    
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor (address crowdsaleAddress) public {
        crowdsale = Crowdsale(crowdsaleAddress);
        crowdsaleToken = WonoToken(crowdsale.getToken());
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
    function setTeamAddress(address a) public onlyOwner() {
        distributionAddress[0] = a;
    }
    
    function setAdvisorAddress(address a) public onlyOwner() {
        distributionAddress[1] = a;
    }
    
    function setRewardsAddress(address a) public onlyOwner() {
        distributionAddress[2] = a;
    }
    
    function setReserveAddress(address a) public onlyOwner() {
        distributionAddress[3] = a;
    }

    // ------------------------------------------------------------------------
    // Winthdrawals
    // ------------------------------------------------------------------------
    function teamWithdraw(uint tokens) {
        
    }
    
    function advisorWithdraw(uint tokens) {
    
    }
    
    function rewardWithdraw(uint tokens) {
    
    }
    
    function reserveWithdraw(uint tokens) {
    
    }
    
}
