// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/DoubleEntryPoint/DoubleEntryPointFactory.sol";
import "../src/Ethernaut.sol";

contract DoubleEntryPointTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testDoubleEntryPointHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////
        DoubleEntryPointFactory doubleEntryPointFactory = new DoubleEntryPointFactory();
        ethernaut.registerLevel(doubleEntryPointFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(doubleEntryPointFactory);
        DoubleEntryPoint doubleEntryPoint = DoubleEntryPoint(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        DetectionBot detectionBot =
            new DetectionBot(address(doubleEntryPoint.forta()), address(doubleEntryPoint.cryptoVault()));
        doubleEntryPoint.forta().setDetectionBot(address(detectionBot));

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}

contract DetectionBot is IDetectionBot, Ownable {
    Forta public immutable forta;
    CryptoVault public immutable cryptoVault;

    constructor(address _forta, address _cryptoVault) Ownable() {
        forta = Forta(_forta);
        cryptoVault = CryptoVault(_cryptoVault);
    }

    function handleTransaction(address, bytes calldata msgData) public override {
        bytes4 sig = bytes4(msgData[0]) | bytes4(msgData[1]) >> 8 | bytes4(msgData[2]) >> 16 | bytes4(msgData[3]) >> 24;
        bytes4 delegateTransferSig = bytes4(keccak256(abi.encodePacked("delegateTransfer(address,uint256,address)")));
        if (sig == delegateTransferSig) {
            (,, address origSender) = abi.decode(msgData[4:], (address, uint256, address)); //msgData[4:] : Skip the first 4 bytes (function selector) and extract the function parameters
            if (origSender == address(cryptoVault)) {
                forta.raiseAlert(owner());
            }
        }
    }
}
