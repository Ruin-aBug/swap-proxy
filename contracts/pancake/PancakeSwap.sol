// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../libraries/TransferHelper.sol";

import "./interfaces/IPancakeRouter.sol";
import "./interfaces/IPancakeFactory.sol";
import "./interfaces/IPancakePair.sol";
import "./info/ConstantAddr.sol";
import "../const/Constant.sol";

contract PancakeSwap is ConstantAddr, Constant {
    //合约接受转 ETH 币功能
    receive() external payable {}

    // 1、获取 pancakeswap 工厂合约地址
    function getPancakeFactory() public pure returns (address) {
        return IPancakeRouter(Router).factory();
    }

    // 2、获取pair的地址
    function getPair(address tokenA, address tokenB)
        public
        view
        returns (address)
    {
        address pairAddress = IPancakeFactory(getPancakeFactory()).getPair(
            tokenA,
            tokenB
        );
        return pairAddress;
    }

    event SwapEvent(uint256 amountOut);

    // 1、用确切的代币交唤其他代币
    function swapExactTokensForTokens(
        uint256 amountIn,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut) {
        require(amountIn > 0, "swap error");
        address router = Router;
        TransferHelper.safeApprove(path[0], router, amountIn);
        uint256 amountOutMin;
        (path, amountOutMin) = getOptimalOut(path[0], path[1], amountIn);
        uint256[] memory amounts = IPancakeRouter(router)
            .swapExactTokensForTokens(
                amountIn,
                (amountOutMin * 995) / 1000,
                path,
                to,
                deadline
            );
        amountOut = amounts[amounts.length - 1];
        emit SwapEvent(amountOut);
    }

    // op swap 功能
    function opSwap(
        uint256 amountIn,
        address[] memory path,
        address to,
        uint256 amountOutMin
    ) external returns(uint256 amountOut) {
        require(amountIn > 0, "swap error");
        address router = Router;
        TransferHelper.safeApprove(path[0], router, amountIn);
        // uint256 OutMin;
        // (path, OutMin) = getOptimalOut(path[0], path[1], amountIn);
        uint256[] memory amounts = IPancakeRouter(router)
            .swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                to,
                block.timestamp + 300
            );
        amountOut = amounts[amounts.length - 1];
    }

    // 2、用代币交唤指定的代币

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
        address router = Router;
        TransferHelper.safeApprove(path[0], router, amountOut);
        amounts = IPancakeRouter(router).swapTokensForExactTokens(
            amountOut,
            amountInMax,
            path,
            to,
            deadline
        );
    }

    /**
     * 查询对币交易所有存在路径
     */
    function getAllPath(address tokenA, address tokenB)
        public
        view
        returns (address[][] memory)
    {
        address[] memory path; // 单个路径
        address[][] memory paths = new address[][](26); // 多路径集合
        uint256 index = 0;
        if (getPair(tokenA, tokenB) != address(0)) {
            path = new address[](2);
            path[0] = tokenA;
            path[1] = tokenB;
            paths[index] = path;
            index++;
        }
        // 获取所有兑换路径
        for (uint256 i = 0; i < baseToken.length; i++) {
            if (getPair(tokenA, baseToken[i]) != address(0)) {
                if (getPair(baseToken[i], tokenB) != address(0)) {
                    path = new address[](3);
                    path[0] = tokenA;
                    path[1] = baseToken[i];
                    path[2] = tokenB;
                    paths[index] = path;
                    index++;
                }
                for (uint256 j = i; j < baseToken.length; j++) {
                    if (
                        getPair(tokenA, baseToken[i]) != address(0) &&
                        getPair(baseToken[i], baseToken[j]) != address(0) &&
                        getPair(baseToken[j], tokenB) != address(0)
                    ) {
                        path = new address[](4);
                        path[0] = tokenA;
                        path[1] = baseToken[i];
                        path[2] = baseToken[j];
                        path[3] = tokenB;
                        paths[index] = path;
                        index++;
                    }
                }
            }
        }

        // 查询有效路径
        uint256 a;
        for (a = 0; a < paths.length; a++) {
            if (paths[a].length == 0) {
                break;
            }
        }
        // 有效长度的数组
        address[][] memory activePaths = new address[][](a);
        for (a; a > 0; a--) {
            activePaths[a - 1] = paths[a - 1];
        }

        return activePaths;
    }

    function getOptimalOut(
        address tokenA,
        address tokenB,
        uint256 amountIn
    ) public view returns (address[] memory, uint256) {
        address[][] memory paths = getAllPath(tokenA, tokenB);
        uint256 amountOut;
        uint256 index;
        for (uint256 i; i < paths.length; i++) {
            (index, amountOut) = amountOut > getOutValue(paths[i], amountIn)
                ? (index, amountOut)
                : (i, getOutValue(paths[i], amountIn));
        }
        return (paths[index], amountOut);
    }

    function getOptimalIn(
        address tokenA,
        address tokenB,
        uint256 amountOut
    ) public view returns (address[] memory, uint256) {
        address[][] memory paths = getAllPath(tokenA, tokenB);
        uint256 amountIn;
        uint256 index;
        for (uint256 i; i < paths.length; i++) {
            (index, amountIn) = amountIn < getInValue(paths[i], amountOut) &&
                amountIn > 0
                ? (index, amountIn)
                : (i, getInValue(paths[i], amountOut));
        }
        return (paths[index], amountIn);
    }

    function getOutValue(address[] memory path, uint256 amountIn)
        public
        view
        returns (uint256)
    {
        if (amountIn == 0) {
            return 0;
        }
        try IPancakeRouter(Router).getAmountsOut(amountIn, path) returns (
            uint256[] memory amounts
        ) {
            return amounts[amounts.length - 1];
        } catch {
            return 0;
        }
    }

    function getInValue(address[] memory path, uint256 amountOut)
        public
        view
        returns (uint256)
    {
        if (amountOut == 0) {
            return 0;
        }
        try IPancakeRouter(Router).getAmountsIn(amountOut, path) returns (
            uint256[] memory amounts
        ) {
            return amounts[0];
        } catch {
            return type(uint256).max;
        }
    }
}
