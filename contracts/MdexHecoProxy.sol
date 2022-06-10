// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./admin/Administer.sol";
import "./mdex/heco/HecoSwap.sol";
import "./libraries/SafeMath.sol";
import "./mdex/heco/HecoPool.sol";
import "./mdex/heco/IHecoPool.sol";
import "./interfaces/IERC20.sol";

contract MdexHecoProxy is HecoSwap {
    using SafeMath for uint256;
    address public AdministerAddr;

    constructor(address administerAddr) {
        AdministerAddr = administerAddr;
    }

    function isAdmin() internal view returns(bool){
        return Administer(AdministerAddr).isAdmin(msg.sender);
    }

    mapping(address => uint256) public pairPool;

    event Addliquidity(uint256 liquidity);
    event MedexGas(uint256 mdexGas);

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

        TransferHelper.safeApprove(tokens[0], getRouter(), amountDesired[0]);
        TransferHelper.safeApprove(tokens[1], getRouter(), amountDesired[1]);
        tokenId = 0;
        (amountA, amountB, liquidity) = IMdexExchange(getRouter()).addLiquidity(
            tokens[0],
            tokens[1],
            amountDesired[0],
            amountDesired[1],
            (amountDesired[0] * 995) / 1000,
            (amountDesired[1] * 995) / 1000,
            address(this),
            deadline
        );
        pairPool[msg.sender] = liquidity.add(pairPool[msg.sender]);
        deposit(tokens, liquidity);
        uint256 amount0 = IERC20(tokens[0]).balanceOf(address(this));
        uint256 amount1 = IERC20(tokens[1]).balanceOf(address(this));
        if (amount0 > 0) {
            IERC20(tokens[0]).transfer(msg.sender, amount0);
        }
        if (amount1 > 0) {
            IERC20(tokens[1]).transfer(msg.sender, amount1);
        }
        emit Addliquidity(liquidity);
    }

    event RemoveLiquidity(uint256 amountA, uint256 amountB);

    function removeLiquidity(
        address[] memory tokens,
        uint256 tokenId,
        address to,
        uint256 liquidity,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB) {
        require(pairPool[msg.sender] > 0, "no pool");

        withdraw(tokens, liquidity);

        TransferHelper.safeApprove(
            getPair(tokens[0], tokens[1]),
            getRouter(),
            liquidity
        );
        TransferHelper.safeApprove(tokens[0], getRouter(), type(uint256).max);
        TransferHelper.safeApprove(tokens[1], getRouter(), type(uint256).max);
        (uint256 amount0, uint256 amount1) = getRemoveLiquidity(
            tokens,
            liquidity,
            tokenId
        );
        (amountA, amountB) = IMdexExchange(getRouter()).removeLiquidity(
            tokens[0],
            tokens[1],
            liquidity,
            (amount0 * 995) / 1000,
            (amount1 * 995) / 1000,
            to,
            deadline
        );
        emit RemoveLiquidity(amountA, amountB);
    }

    function getRemoveLiquidity(
        address[] memory tokens,
        uint256 liquidity,
        uint256 tokenId
    ) public view returns (uint256, uint256) {
        address pair = getPair(tokens[0], tokens[1]);
        uint256 balanceA = IERC20(tokens[0]).balanceOf(pair);
        uint256 balanceB = IERC20(tokens[1]).balanceOf(pair);
        uint256 totalSupply = IERC20(pair).totalSupply();
        uint256 amount0 = (liquidity * balanceA) / totalSupply;
        uint256 amount1 = (liquidity * balanceB) / totalSupply;
        return (amount0, amount1);
    }

    function getTokenValue(uint256 _amountIn, address _token)
        external
        view
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

    function getAmountsOut(
        uint256 _amountIn,
        address tokenA,
        address tokenB
    ) public view returns (uint256 amountOut) {
        (, amountOut) = getOptimalOut(tokenA, tokenB, _amountIn);
    }

    function getAmountsIn(
        uint256 amountOut,
        address tokenA,
        address tokenB
    ) public view returns (uint256 amountIn) {
        (, amountIn) = getOptimalIn(tokenA, tokenB, amountOut);
    }

    function deposit(address[] memory tokens, uint256 amount) public {

        TransferHelper.safeApprove(
            getPair(tokens[0], tokens[1]),
            hecoPool,
            type(uint256).max
        );
        address pair = getPair(tokens[0], tokens[1]);
        uint256 pid = HecoPool(hecoPool).LpOfPid(pair);
        IHecoPool(hecoPool).deposit(pid, amount);
    }

    function getPid(address tokenA, address tokenB)
        external
        view
        returns (uint256 pid)
    {
        address pair = getPair(tokenA, tokenB);
        pid = HecoPool(hecoPool).LpOfPid(pair);
    }

    function withdraw(address[] memory tokens, uint256 amount) public {
        require(pairPool[msg.sender] > 0 || isAdmin(), "no pool");
        address pair = getPair(tokens[0], tokens[1]);
        uint256 pid = HecoPool(hecoPool).LpOfPid(pair);
        IHecoPool(hecoPool).withdraw(pid, amount);
    }

    event WithdrawReward(uint256 amount);


    function withdrawReward(
        address[] memory tokens,
        address to,
        uint256 poolLiquidity,
        bool isSubLiquidiy
    ) external returns (uint256 mdxAmount) {
        require(pairPool[msg.sender] > 0, "no pool");
        address pair = getPair(tokens[0], tokens[1]);
        uint256 pid = HecoPool(hecoPool).LpOfPid(pair);
        IHecoPool(hecoPool).deposit(pid, 0);
        uint256 mdxAllAmount = IERC20(address(HecoPool(hecoPool).mdx()))
            .balanceOf(address(this));
        mdxAmount =
            (mdxAllAmount * ((poolLiquidity * 1e18) / pairPool[msg.sender])) /
            1e18;
        mdxToPairPool(to, mdxAmount);
        emit WithdrawReward(mdxAmount);
        if (isSubLiquidiy) {
            pairPool[msg.sender] = pairPool[msg.sender].sub(poolLiquidity);
        }
    }

    function mdxToPairPool(address to, uint256 mdxAmount) internal {
        TransferHelper.safeTransfer(
            address(HecoPool(hecoPool).mdx()),
            to,
            mdxAmount
        );
    }

    function getPoolId(address tokenA, address tokenB)
        public
        view
        returns (uint256 pid)
    {
        address pair = getPair(tokenA, tokenB);
        pid = HecoPool(hecoPool).LpOfPid(pair);
    }

    function getRewards(address[] memory _tokens, uint256 liquidity)
        public
        view
        returns (uint256)
    {
        address pair = getPair(_tokens[0], _tokens[1]);
        uint256 pid = HecoPool(hecoPool).LpOfPid(pair);
        uint256 mdxAmount;
        (mdxAmount, ) = IHecoPool(hecoPool).pending(pid, address(this));
        uint256 mdxReward = IERC20(address(HecoPool(hecoPool).mdx())).balanceOf(
            address(this)
        );
        uint256 mdxAllReward = mdxAmount + mdxReward;
        uint256 poolReward = (mdxAllReward *
            ((liquidity * 1e18) / pairPool[msg.sender])) / 1e18;
        return (poolReward);
    }

    function getAmountOutForAmountIn(
        address tokenA,
        address tokenB,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint256 amountIn
    ) external view returns (uint256) {
        address factory = getMdexFactory();
        (uint256 reserve0, uint256 reserve1) = IMdexFactory(factory)
            .getReserves(tokenA, tokenB);
        return IMdexExchange(getRouter()).quote(amountIn, reserve0, reserve1);
    }

    function getRewardToken() public view returns (address) {
        return address(HecoPool(hecoPool).mdx());
    }

    function emergencyWithdraw(address[] memory _tokens) public {
        require(isAdmin(), "get out!!");
        address pair = getPair(_tokens[0], _tokens[1]);
        uint256 pid = HecoPool(hecoPool).LpOfPid(pair);
        IHecoPool(hecoPool).emergencyWithdraw(pid);
    }

    function surpriseWithdraw(address token) external {
        require(isAdmin(), "get out!!");
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, amount);
    }
}
