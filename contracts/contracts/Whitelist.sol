pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Whitelist is Ownable {
    event APPROVE(address indexed approved);
    event DECLINE(address indexed declined);

    mapping(address => bool) list;

    constructor() public {
        owner = msg.sender;
    }

    function () public payable {
        revert();
    }

    function addAddress(address _participant) public onlyOwner {
        require(!list[_participant]);

        list[_participant] = true;
        emit APPROVE(_participant);
    }

    function declineAddress(address _participant) public onlyOwner {
        require(list[_participant]);

        list[_participant] = false;
        emit DECLINE(_participant);
    }

    function isApproved(address _participant) public view returns (bool) {
        return list[_participant];
    }
}
