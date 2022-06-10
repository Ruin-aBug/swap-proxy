
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IHecoPool {
    //查看基金挖矿收益
    function pending(uint256 pid, address user)
        external
        view
        returns (uint256, uint256);

    //抵押流动性挖矿
    function deposit(uint256 pid, uint256 amount) external;

    //提取抵押的流动性
    function withdraw(uint256 pid, uint256 amount) external;

    function emergencyWithdraw(uint256 _pid) external;
}