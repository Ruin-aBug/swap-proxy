// 流动性挖矿合约
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

// import "../../../interfaces/IERC20.sol";
contract CakeVault{

    struct UserInfo {
        uint256 shares;                 // number of shares for a user
        uint256 lastDepositedTime;      // keeps track of deposited time for potential penalty
        uint256 cakeAtLastUserAction;   // keeps track of cake deposited at the last user action
        uint256 lastUserActionTime;     // 跟踪上次用户操作时间
    }

    mapping(address => UserInfo) public userInfo;
}