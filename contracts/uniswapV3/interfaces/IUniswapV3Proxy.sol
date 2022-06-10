// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;
import "./IV3PoolStruct.sol";


interface IUniswapV3Proxy is IV3PoolStruct {
    // 1、换币
    function swap(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        address to,
        uint256 amountIn
    ) external payable returns (uint256);

    // 2、获取价格
    function getPrice(
        address tokenIn,
        address tokenOut,
        uint24 fee
    ) external returns (uint256);

    // 3、获取池子地址
    function getPoolAddress(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address);

    // 4、获取池子当前相关信息
    function getPoolSlot(
        address tokenA,
        address tokenB,
        uint24 fee
    )
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    // 5、获取多个 tick
    function tickBitmap(int16 wordPosition, address pool)
        external
        view
        returns (uint256);

    // 6、获取 tick 相关信息
    function ticks(int24 tick, address pool)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    // 7、获取 tick 的间距
    function tickSpacing(address pool) external view returns (int24);

    // 8、通过 tokenId 获取 NFT 的相关信息
    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address tokenA,
            address tokenB,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    // 9、第一次添加流动性的时候将返回 NFT (在同一个 tick 范围上只会返回一个 NFT)
    function mint(MintParams memory params)
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    // 10、在该 tick 范围中非第一次添加流动性时调用
    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    // 11、移除流动性
    function decreaseLiquidity(DecreaseLiquidityParams memory params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    // 12、缴纳费用
    function collect(CollectParams memory params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

}
