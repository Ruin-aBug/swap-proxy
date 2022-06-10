// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

// import "../../../interfaces/IERC20.sol";

// 自动复利 cake
interface ICakeVault {
    // 抵押 cake
    function deposit(uint256 _amount) external;

    // 提取 用户的所有挖矿份额
    function withdrawAll() external;

    function withdraw(uint256 _shares) external;

    // 计算第三方的预期收获奖励
    function calculateHarvestCakeRewards() external view returns (uint256);

    // 查询用户信息
    function userInfo(address _user) external view returns (uint256, uint256, uint256, uint256);
}
