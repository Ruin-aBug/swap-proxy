// 流动性挖矿合约
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
import "../../interfaces/IERC20.sol";
contract MasterChef{
    // using SafeMath for uint256;
    // using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        IERC20 lpToken; // LP令牌合同的地址。
        uint256 allocPoint; // 分配给该池的分配点数。使用它按块分发。
        uint256 lastRewardBlock; // 支持此分布发生的最后一个块号。
        uint256 accSushiPerShare; // 累计每股收益，乘以1e12。见下文
    }
    PoolInfo[] public poolInfo;

    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
}