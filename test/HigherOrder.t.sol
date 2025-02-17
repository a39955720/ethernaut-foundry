// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
// import "../src/HigherOrder/HigherOrderFactory.sol";
import "../src/Ethernaut.sol";

contract HigherOrderTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contracts
        ethernaut = new Ethernaut();
    }

    function testHigherOrderHack() public {
        // /////////////////
        // // LEVEL SETUP //
        // /////////////////

        // HigherOrderFactory higherOrderFactory = new HigherOrderFactory();
        // ethernaut.registerLevel(higherOrderFactory);
        // vm.startPrank(tx.origin);
        // address levelAddress = ethernaut.createLevelInstance(higherOrderFactory);
        // HigherOrder ethernautHigherOrder new HigherOrder();

        // //////////////////
        // // LEVEL ATTACK //
        // //////////////////);
        // (bool success,) =
        // address(ethernautHigherOrder).call(abi.encodeWithSignature("registerTreasury(uint8)", uint16(0x100)));
        // require(success, "registerTreasury failed");
        // ethernautHigherOrder.claimLeadership();

        // //////////////////////
        // // LEVEL SUBMISSION //
        // //////////////////////

        // bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        // vm.stopPrank();
        // assert(levelSuccessfullyPassed);
    }
}
