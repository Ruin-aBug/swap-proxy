// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

// import "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import "@uniswap/v3-core/contracts/libraries/SafeCast.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

import "./uniswapV3/libraries/TickMath.sol";
import "./uniswapV3/libraries/LiquidityAmounts.sol";
import "./uniswapV3/libraries/PoolAddress.sol";
import "./uniswapV3/interfaces/INonfungiblePositionManager.sol";
import "./uniswapV3/interfaces/ISwapRouter.sol";
import "./uniswapV3/interfaces/IQuoter.sol";
import "./libraries/TransferHelper.sol";
import "./uniswapV3/constantInfo/ConstantInfo.sol";
import "./const/Constant.sol";
import "./libraries/Library.sol";
import "./libraries/SafeMath.sol";


contract UniswapV3Proxy is
    ISwapRouter,
    INonfungiblePositionManager,
    ConstantInfo,
    Constant
{
    // address public SWAP_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    // address public QUOTER_ROUTER = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;
    // address public factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    // address public NonfungiblePositionManager =
    //     0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    using SafeMath for uint256;
    uint24[] fees = [500, 3000, 10000];
    mapping(address => uint256) public pairPool;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory) {
        TransferHelper.safeApprove(path[0], SWAP_ROUTER, type(uint256).max);
        uint24 fee;
        (fee, amountOutMin) = _getAmountsOut(amountIn, path[0], path[1]);
        uint256 amountOut = exactInputSingle(
            ExactInputSingleParams({
                tokenIn: path[0],
                tokenOut: path[1],
                fee: fee,
                recipient: to,
                deadline: deadline,
                amountIn: amountIn,
                amountOutMinimum: (amountOutMin * 995) / 1000,
                sqrtPriceLimitX96: 0
            })
        );
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = amountIn;
        amounts[1] = amountOut;
        return amounts;
    }

    function getAmountsOut(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) public returns (uint256) {
        // TransferHelper.safeApprove(tokenIn, QUOTER_ROUTER, type(uint256).max);
        (, uint256 temp) = _getAmountsOut(amountIn, tokenIn, tokenOut);
        return temp;
    }

    function getAmountsIn(
        uint256 amountOut,
        address tokenIn,
        address tokenOut
    ) public returns (uint256) {
        (, uint256 temp) = _getAmountsOut(amountOut, tokenIn, tokenOut);
        return temp;
    }

    function _getAmountsOut(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) internal returns (uint24, uint256) {
        uint24 fee;
        uint256 amountOut;
        for (uint8 i; i < 3; i++) {
            try
                IQuoter(QUOTER_ROUTER).quoteExactInputSingle(
                    tokenIn,
                    tokenOut,
                    fees[i],
                    amountIn,
                    0
                )
            returns (uint256 temp) {
                (fee, amountOut) = amountOut > temp
                    ? (fee, amountOut)
                    : (fees[i], temp);
            } catch {}
        }
        return (fee, amountOut);
    }

    function getTokenValue(uint256 _amountIn, address _token)
        external
        returns (uint256)
    {
        if (_token == USDT) {
            return _amountIn;
        }
        if (_amountIn > 0) {
            return getAmountsOut(_amountIn, _token, USDT);
        } else {
            return 0;
        }
    }

    function exactInputSingle(ExactInputSingleParams memory params)
        public
        payable
        override
        returns (uint256 amountOut)
    {
        amountOut = ISwapRouter(SWAP_ROUTER).exactInputSingle(params);
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata _data
    ) external override {}


    function _floor(int24 tick, address pool) internal view returns (int24) {
        int24 compressed = tick / tickSpacing(pool);
        if (tick < 0 && tick % tickSpacing(pool) != 0) compressed--;
        return compressed * tickSpacing(pool);
    }

    function _ceil(int24 tick, address pool) internal view returns (int24) {
        int24 floor = _floor(tick, pool);
        return floor + tickSpacing(pool);
    }

    function getPair(
        address tokenA,
        address tokenB,
        uint24 fee
    ) public pure returns (address) {
        return
            PoolAddress.computeAddress(
                factory,
                PoolAddress.getPoolKey(tokenA, tokenB, fee)
            );
    }

    function getPoolSlot(
        address tokenA,
        address tokenB,
        uint24 fee
    )
        public
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        )
    {
        address pool = getPair(tokenA, tokenB, fee);
        return IUniswapV3Pool(pool).slot0();
    }

    function getLiquidity(
        address tokenA,
        address tokenB,
        uint24 fee
    ) public view returns (uint128) {
        return IUniswapV3Pool(getPair(tokenA, tokenB, fee)).liquidity();
    }

    function getAmountsForLiquidity(
        address tokenA,
        address tokenB,
        uint128 liquidity,
        uint256 tokenId
    ) public view returns (uint256 amount0, uint256 amount1) {
        (
            ,
            ,
            ,
            ,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            ,
            ,
            ,
            ,

        ) = positions(tokenId);
        // address pool = getPair(tokenA, tokenB, fee);
        (uint160 sqrtRatioX96, , , , , , ) = getPoolSlot(tokenA, tokenB, fee);
        // uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);
        uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(tickUpper);
        (amount0, amount1) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtRatioX96,
            sqrtRatioAX96,
            sqrtRatioBX96,
            liquidity
        );
    }

    function getRewards(address[] memory tokens, uint256 liquidity)
        external
        pure
        returns (uint256)
    {
        return 0;
    }

    function getRemoveLiquidity(
        address[] memory tokens,
        uint256 liquidity,
        uint256 tokenId
    ) external view returns (uint256 amount0, uint256 amount1) {
        (amount0, amount1) = getAmountsForLiquidity(
            tokens[0],
            tokens[1],
            uint128(liquidity),
            tokenId
        );
    }

    function tickBitmap(int16 wordPosition, address pool)
        external
        view
        returns (uint256)
    {
        return IUniswapV3Pool(pool).tickBitmap(wordPosition);
    }

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
        )
    {
        return IUniswapV3Pool(pool).ticks(tick);
    }

    function tickSpacing(address pool) public view returns (int24) {
        return IUniswapV3Pool(pool).tickSpacing();
    }

    function positions(uint256 tokenId)
        public
        view
        override
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
        )
    {
        return
            INonfungiblePositionManager(NonfungiblePositionManager).positions(
                tokenId
            );
    }

    function mint(MintParams memory params)
        public
        payable
        override
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amountA,
            uint256 amountB
        )
    {
        TransferHelper.safeApprove(
            params.token1,
            NonfungiblePositionManager,
            type(uint256).max
        );
        TransferHelper.safeApprove(
            params.token0,
            NonfungiblePositionManager,
            type(uint256).max
        );
        (tokenId, liquidity, amountA, amountB) = INonfungiblePositionManager(
            NonfungiblePositionManager
        ).mint(params);
        uint256 amount0 = IERC20(params.token0).balanceOf(address(this));
        uint256 amount1 = IERC20(params.token1).balanceOf(address(this));
        if (amount0 > 0) {
            IERC20(params.token0).transfer(msg.sender, amount0);
        }
        if (amount1 > 0) {
            IERC20(params.token1).transfer(msg.sender, amount1);
        }
    }

    function addLiquidity(
        address[] memory tokens,
        uint256[] memory amountDesired,
        uint256 _tokenId,
        uint256 deadline
    )
        external
        returns (
            uint256 tokenId,
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        (uint24 fee, int24 tickLower, int24 tickUpper) = Library.getConverData(
            amountDesired[2]
        );
        uint128 _liquidity;
        if (_tokenId == 0) {
            (tokenId, _liquidity, amountA, amountB) = mint(
                MintParams({
                    token0: tokens[0],
                    token1: tokens[1],
                    fee: fee,
                    tickLower: tickLower,
                    tickUpper: tickUpper,
                    amount0Desired: amountDesired[0],
                    amount1Desired: amountDesired[1],
                    amount0Min: (amountDesired[0] * 995) / 1000,
                    amount1Min: (amountDesired[1] * 995) / 1000,
                    recipient: address(this),
                    deadline: deadline
                })
            );
            liquidity = uint256(_liquidity);
        } else {
            tokenId = _tokenId;
            (_liquidity, amountA, amountB) = increaseLiquidity(
                IncreaseLiquidityParams({
                    tokenId: _tokenId,
                    amount0Desired: amountDesired[0],
                    amount1Desired: amountDesired[1],
                    amount0Min: (amountDesired[0] * 995) / 1000,
                    amount1Min: (amountDesired[1] * 995) / 1000,
                    deadline: deadline
                })
            );
            liquidity = uint256(_liquidity);
        }
        pairPool[msg.sender] = pairPool[msg.sender].add(liquidity);
    }

    function increaseLiquidity(IncreaseLiquidityParams memory params)
        public
        payable
        override
        returns (
            uint128 liquidity,
            uint256 amountA,
            uint256 amountB
        )
    {
        (liquidity, amountA, amountB) = INonfungiblePositionManager(
            NonfungiblePositionManager
        ).increaseLiquidity(params);
        (, , address tokenA, address tokenB, , , , , , , , ) = positions(
            params.tokenId
        );
        uint256 amount0 = IERC20(tokenA).balanceOf(address(this));
        uint256 amount1 = IERC20(tokenB).balanceOf(address(this));
        if (amount0 > 0) {
            IERC20(tokenA).transfer(msg.sender, amount0);
        }
        if (amount1 > 0) {
            IERC20(tokenB).transfer(msg.sender, amount1);
        }
    }

    function decreaseLiquidity(DecreaseLiquidityParams memory params)
        public
        payable
        override
        returns (uint256 amount0, uint256 amount1)
    {
        require(pairPool[msg.sender] > 0, "no pool");
        (uint256 amA, uint256 amB) = INonfungiblePositionManager(
            NonfungiblePositionManager
        ).decreaseLiquidity(params);

        (amount0, amount1) = collect(
            CollectParams({
                tokenId: params.tokenId,
                recipient: address(this),
                amount0Max: uint128(amA),
                amount1Max: uint128(amB)
            })
        );
        (, , address tokenA, address tokenB, , , , , , , , ) = positions(
            params.tokenId
        );
        TransferHelper.safeTransfer(tokenA, msg.sender, amount0);
        TransferHelper.safeTransfer(tokenB, msg.sender, amount1);
        pairPool[msg.sender] = pairPool[msg.sender].sub(params.liquidity);
    }

    function collect(CollectParams memory params)
        public
        payable
        override
        returns (uint256 amount0, uint256 amount1)
    {
        (amount0, amount1) = INonfungiblePositionManager(
            NonfungiblePositionManager
        ).collect(params);
    }

    function removeLiquidity(
        address[] memory token,
        uint256 tokenId,
        address to,
        uint256 liquidity,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB) {
        require(pairPool[msg.sender] > 0, "no pool");
        (uint256 amount0, uint256 amount1) = getAmountsForLiquidity(
            token[0],
            token[1],
            uint128(liquidity),
            tokenId
        );
        (amountA, amountB) = decreaseLiquidity(
            DecreaseLiquidityParams({
                tokenId: tokenId,
                liquidity: uint128(liquidity),
                amount0Min: (amount0 * 995) / 1000,
                amount1Min: (amount1 * 995) / 1000,
                deadline: deadline
            })
        );
    }

    function getAmountOutForAmountIn(
        address tokenA,
        address tokenB,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint256 amountIn
    ) public view returns (uint256 amountOut) {
        address pool = getPair(tokenA, tokenB, fee);
        (uint160 sqrtRatioX96, , , , , , ) = IUniswapV3Pool(pool).slot0();
        uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(tickUpper);
        uint128 liquidity0 = LiquidityAmounts.getLiquidityForAmount0(
            sqrtRatioX96,
            sqrtRatioBX96,
            amountIn
        );
        amountOut = LiquidityAmounts.getAmount1ForLiquidity(
            sqrtRatioAX96,
            sqrtRatioX96,
            liquidity0
        );
    }

    function getAmountInForAmountOut(
        address tokenB,
        address tokenA,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint256 amountOut
    ) public view returns (uint256 amountIn) {
        address pool = getPair(tokenA, tokenB, fee);
        (uint160 sqrtRatioX96, , , , , , ) = IUniswapV3Pool(pool).slot0();
        uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(tickUpper);
        uint128 liquidity = LiquidityAmounts.getLiquidityForAmount1(
            sqrtRatioAX96,
            sqrtRatioX96,
            amountOut
        );
        amountIn = LiquidityAmounts.getAmount0ForLiquidity(
            sqrtRatioX96,
            sqrtRatioBX96,
            liquidity
        );
    }

    //
    function burn(uint256 tokenId) external payable override {}

    function getRewardToken() external pure returns (address) {
        return address(0);
    }
}
