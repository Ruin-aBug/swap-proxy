// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../../interfaces/IERC20.sol";

interface IMasterChef {
    // 1、获取池子长度
    function poolLength() external view returns (uint256);

    // 2、抵押
    function deposit(uint256 _pid, uint256 _amount) external;

    // 3、提取
    function withdraw(uint256 _pid, uint256 _amount) external;

    // 4、查询挖矿收益
    function pendingCake(uint256 _pid, address _user) external view returns (uint256);

    // 5、不在乎奖励提取全部流动性挖矿的 lpToken。仅限紧急情况。
    function emergencyWithdraw(uint256 _pid) external;

    // 6、将给定池的奖励变量更新为最新。
    function updatePool(uint256 _pid) external;

    // 查询用户信息
    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);

////////////////////////////////////////////////////////////////
    // 单币 cake 挖矿 cake
    // 7、抵押 cake 赚取糖浆币
    function enterStaking(uint256 _amount) external;

    // 8、提取 cake 币
    function leaveStaking(uint256 _amount) external;
}
