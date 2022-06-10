// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../../interfaces/IERC20.sol";

contract SmartChefInitializable {
    IERC20 public rewardToken;

    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }
    


}


