// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../interfaces/IERC20.sol";
//一切参数名称不能改！！！
contract HecoPool {
    IERC20 public mdx;
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt.
        uint256 multLpRewardDebt; //multLp Reward debt.
    }

    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    mapping(address => uint256) public LpOfPid;
}

