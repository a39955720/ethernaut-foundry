// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../BaseLevel.sol";
import "./Stake.sol";

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StakeFactory is Level {
    address _dweth = address(new ERC20("DummyWETH", "DWETH"));

    function createInstance(address _player) public payable override returns (address) {
        return address(new Stake(address(_dweth)));
    }

    function validateInstance(address payable _instance, address _player) public view override returns (bool) {
        Stake instance = Stake(_instance);
        return _instance.balance != 0 && instance.totalStaked() > _instance.balance && instance.UserStake(_player) == 0
            && instance.Stakers(_player);
    }
}
