// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

// import "../../../interfaces/IERC20.sol";

interface ISmartChefInitializable {

    // 1、抵押
    function deposit(uint256 _amount) external;

    // 2、提取
    function withdraw(uint256 _amount) external;

    // 3、提现质押的代币而不关心奖励奖励
    function emergencyWithdraw() external;

    // 4、查看函数以查看前端的悬而未决奖励。
    function pendingReward(address _user) external view returns (uint256);

    // 查询用户信息
    function userInfo(address _user) external view returns (uint256, uint256);

}
