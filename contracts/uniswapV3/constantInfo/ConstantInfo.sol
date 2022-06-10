// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * 常量合约,V3 的相关链上地址
 */
contract ConstantInfo {
    address public constant SWAP_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address public constant QUOTER_ROUTER = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;
    address public constant factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address public constant NonfungiblePositionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
}