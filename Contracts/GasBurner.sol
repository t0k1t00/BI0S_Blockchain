// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract GasBurner {
    uint256 n;

    function burn() internal {
        while (gasleft() > 0) {
            n += 1;
        }
    }

    receive() external payable {
        burn();
    }
}
//Gas Burner at 0x0b0fE8D33C3e1FB117ca9665F0E79De16b3F8Cd1
