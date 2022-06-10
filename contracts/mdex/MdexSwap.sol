// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../libraries/TransferHelper.sol";
import "./interfaces/IMdexExchange.sol";
import "./interfaces/IMdexRouter.sol";
import "./interfaces/IMdexFactory.sol";
import "../const/Constant.sol";

abstract contract MdexSwap is Constant {
    receive() external payable {}

    function getRouter() public pure virtual returns (address);

    function getMdexFactory() internal pure returns (address) {
        return IMdexExchange(getRouter()).factory();
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut) {
        require(amountIn > 0, "swap error");
        address router = getRouter();
        TransferHelper.safeApprove(path[0], router, amountIn);
        uint256 amountOutMin;
        (path, amountOutMin) = getOptimalOut(path[0], path[1], amountIn);
        uint256[] memory amounts = IMdexRouter(router).swapExactTokensForTokens(
            amountIn,
            (amountOutMin * 995) / 1000,
            path,
            to,
            deadline
        );
        amountOut = amounts[amounts.length - 1];
    }


    function opSwap(
        uint256 amountIn,
        address[] memory path,
        address to,
        uint256 amountOutMin
    ) external returns(uint256 amountOut) {
        require(amountIn > 0, "swap error");
        address router = getRouter();
        TransferHelper.safeApprove(path[0], router, amountIn);
        // uint256 OutMin;
        // (path, OutMin) = getOptimalOut(path[0], path[1], amountIn);
        uint256[] memory amounts = IMdexRouter(router).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            block.timestamp + 300
        );
        amountOut = amounts[amounts.length - 1];
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
        address router = getRouter();
        TransferHelper.safeApprove(path[0], router, amountOut);
        amounts = IMdexRouter(router).swapTokensForExactTokens(
            amountOut,
            amountInMax,
            path,
            to,
            deadline
        );
    }

    function getAllPath(address tokenA, address tokenB)
        public
        view
        returns (address[][] memory)
    {
        address[] memory path;
        address[][] memory paths = new address[][](26);
        uint256 index = 0;
        if (getPair(tokenA, tokenB) != address(0)) {
            path = new address[](2);
            path[0] = tokenA;
            path[1] = tokenB;
            paths[index] = path;
            index++;
        }

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

        uint256 a;
        for (a = 0; a < paths.length; a++) {
            if (paths[a].length == 0) {
                break;
            }
        }

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
        // (index,amountIn) = (0,getInValue(paths[0], amountOut));
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
        try IMdexExchange(getRouter()).getAmountsOut(amountIn, path) returns (
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
        try IMdexExchange(getRouter()).getAmountsIn(amountOut, path) returns (
            uint256[] memory amounts
        ) {
            return amounts[0];
        } catch {
            return type(uint256).max;
        }
    }

    function getPair(address tokenA, address tokenB)
        public
        view
        returns (address)
    {
        address pairAddress = IMdexFactory(getMdexFactory()).getPair(
            tokenA,
            tokenB
        );
        return pairAddress;
    }
}
