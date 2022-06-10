// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./admin/Administer.sol";
import "./libraries/SafeMath.sol";
import "./sushiswap/info/MasterChef.sol";
import "./interfaces/IERC20.sol";
import "./sushiswap/interfaces/IMasterChef.sol";
import "./sushiswap/ESuShiSwap.sol";

contract SuShiSwapProxy is ESuShiSwap {
    using SafeMath for uint256;
    address public AdministerAddr;

    constructor(address administerAddr) {
        AdministerAddr = administerAddr;
    }

    mapping(address => uint256) public pairPool;
    mapping(address => uint256) public pidInfo;

    function isAdmin() internal view returns(bool){
        return Administer(AdministerAddr).isAdmin(msg.sender);
    }

    function setPidInfo(address pair, uint256 pid) external {
        require(isAdmin(), "get out!!");
        pidInfo[pair] = pid;
    }

    function getReserves(address tokenA, address tokenB)
        public
        view
        returns (uint256 reserve0, uint256 reserve1)
    {
        address pair = getPair(tokenA, tokenB);
        (reserve0, reserve1, ) = IUniswapV2Pair(pair).getReserves();
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

        TransferHelper.safeApprove(tokens[0], Router, amountDesired[0]);
        TransferHelper.safeApprove(tokens[1], Router, amountDesired[1]);
        tokenId = 0;
        (amountA, amountB, liquidity) = IUniswapV2Router(Router).addLiquidity(
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
    }

    function removeLiquidity(
        address[] memory tokens,
        uint256 tokenId,
        address to,
        uint256 liquidity,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB) {
        require(pairPool[msg.sender] > 0 || isAdmin(), "no pool");

        withdraw(tokens, liquidity);

        TransferHelper.safeApprove(
            getPair(tokens[0], tokens[1]),
            Router,
            liquidity
        );
        TransferHelper.safeApprove(tokens[0], Router, type(uint256).max);
        TransferHelper.safeApprove(tokens[1], Router, type(uint256).max);
        (uint256 amount0, uint256 amount1) = getRemoveLiquidity(
            tokens,
            liquidity,
            tokenId
        );
        (amountA, amountB) = IUniswapV2Router(Router).removeLiquidity(
            tokens[0],
            tokens[1],
            liquidity,
            (amount0 * 995) / 1000,
            (amount1 * 995) / 1000,
            to,
            deadline
        );
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

    function poolLength() public view returns (uint256) {
        uint256 length = IMasterChef(MasterChefAddr).poolLength();
        return length;
    }

    function deposit(address[] memory tokens, uint256 amount) public {
        address pair = getPair(tokens[0], tokens[1]);
        TransferHelper.safeApprove(
            pair,
            MasterChefAddr,
            type(uint256).max
        );
        uint256 pid = pidInfo[pair];
        IMasterChef(MasterChefAddr).deposit(pid, amount);
    }

    function getPid(address tokenA, address tokenB)
        public
        view
        returns (uint256)
    {
        address pair = getPair(tokenA, tokenB);
        for (uint256 index = 0; index < poolLength(); index++) {
            (IERC20 lpToken, , , ) = MasterChef(MasterChefAddr).poolInfo(index);
            if (pair == address(lpToken)) {
                return index;
            }
        }
        revert("no pool");
    }

    function withdraw(address[] memory tokens, uint256 amount) public {
        require(pairPool[msg.sender] > 0 || isAdmin(), "no pool");
        address pair = getPair(tokens[0], tokens[1]);
        uint256 pid = pidInfo[pair];
        IMasterChef(MasterChefAddr).withdraw(pid, amount);
    }

    function withdrawReward(
        address[] memory tokens,
        address to,
        uint256 poolLiquidity,
        bool isSubLiqudiity
    ) external returns (uint256 sushiAmount) {
        require(pairPool[msg.sender] > 0, "no pool");
        address pair = getPair(tokens[0], tokens[1]);
        uint256 pid = pidInfo[pair];
        IMasterChef(MasterChefAddr).deposit(pid, 0);
        uint256 sushiAllAmount = IERC20(SushiToken).balanceOf(address(this));
        sushiAmount =
            (sushiAllAmount * ((poolLiquidity * 1e18) / pairPool[msg.sender])) /
            1e18;
        sushiToPairPool(to, sushiAmount);
        if (isSubLiqudiity) {
            pairPool[msg.sender] = pairPool[msg.sender].sub(poolLiquidity);
        }
    }

    function sushiToPairPool(address to, uint256 sushiAmount) internal {
        TransferHelper.safeTransfer(SushiToken, to, sushiAmount);
    }

    function getDepositInfo(
        address _tokenA,
        address _tokenB,
        address to
    ) public view returns (uint256 amount, uint256 rewardDebt) {
        address pair = getPair(_tokenA, _tokenB);
        uint256 pid = pidInfo[pair];
        (amount, rewardDebt) = MasterChef(MasterChefAddr).userInfo(pid, to);
    }

    function getRewards(address[] memory _tokens, uint256 liquidity)
        public
        view
        returns (uint256)
    {
        address pair = getPair(_tokens[0], _tokens[1]);
        uint256 pid = pidInfo[pair];
        uint256 sushiAmount = IMasterChef(MasterChefAddr).pendingSushi(
            pid,
            address(this)
        );
        uint256 sushiReward = IERC20(SushiToken).balanceOf(address(this));
        uint256 sushiAllReward = sushiAmount + sushiReward;
        uint256 poolReward;
        if (pairPool[msg.sender] > 0) {
            poolReward =
                (sushiAllReward * ((liquidity * 1e18) / pairPool[msg.sender])) /
                1e18;
        }
        return poolReward;
    }

    function getAmountOutForAmountIn(
        address tokenA,
        address tokenB,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint256 amountIn
    ) external view returns (uint256) {
        (uint256 reserve0, uint256 reserve1) = getReserves(tokenA, tokenB);
        return IUniswapV2Router(Router).quote(amountIn, reserve0, reserve1);
    }

    function getAmountInForAmountOut(
        address tokenA,
        address tokenB,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint256 amountOut
    ) external view returns (uint256) {
        (uint256 reserve0, uint256 reserve1) = getReserves(tokenA, tokenB);
        return IUniswapV2Router(Router).quote(amountOut, reserve1, reserve0);
    }

    function getRewardToken() public pure returns (address) {
        return SushiToken;
    }

    function emergencyWithdraw(address[] memory _tokens) public {
        require(isAdmin(), "get out!!");
        address pair = getPair(_tokens[0], _tokens[1]);
        uint256 pid = pidInfo[pair];
        IMasterChef(MasterChefAddr).emergencyWithdraw(pid);
    }

    function testWithdraw(address token) external {
        require(isAdmin(), "get out!!");
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, amount);
    }
}
