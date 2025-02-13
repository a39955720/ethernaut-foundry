// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/MagicNum/MagicNumFactory.sol";
import "../src/Ethernaut.sol";

contract MagicNumTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testMagicNum() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        MagicNumFactory magicNumFactory = new MagicNumFactory();
        ethernaut.registerLevel(magicNumFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(magicNumFactory);
        MagicNum ethernautMagicNum = MagicNum(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        //1.Contract Creation Code
        // PUSH1 0x0a       [0x0a]
        // PUSH1 0x0c       [0x0c, 0x0a]
        // PUSH1 0x00       [0x00, 0x0c, 0x0a]
        // CODECOPY         []          copy code to memory
        // PUSH1 0x0a       [0x0a]
        // PUSH1 0x00       [0x00, 0x0a]
        // RETURN           []          return memory[0x00..0x0a] (the first 0x0a bytes of the runtime code)

        //2.Contract Runtime Code
        // PUSH1 0x2a       [0x2a]
        // PUSH1 0x80       [0x80, 0x2a]
        // MSTORE           []          store 0x80 at memory slot 0
        // PUSH1 0x20       [0x20]
        // PUSH1 0x80       [0x80, 0x20]
        // RETURN           []          return 0x80 bytes of memory starting at slot 0

        bytes memory deployBytecode = hex"600a600c600039600a6000f3602a60805260206080f3";
        address contractAddr;
        assembly {
            contractAddr := create(0, add(deployBytecode, 0x20), mload(deployBytecode))
        }
        ethernautMagicNum.setSolver(contractAddr);

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
