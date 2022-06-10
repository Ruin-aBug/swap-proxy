// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../../interfaces/IERC20.sol";

interface IMasterChef {
    // 获取池子长度
    function poolLength() external view returns (uint256);

    // 抵押
    function deposit(uint256 _pid, uint256 _amount) external;

    // 提取
    function withdraw(uint256 _pid, uint256 _amount) external;

    // 查询挖矿收益
    function pendingSushi(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    // 不在乎奖励提取全部流动性挖矿的 lpToken。仅限紧急情况。
    function emergencyWithdraw(uint256 _pid) external;

    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) external;
}
