// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./admin/Administer.sol";
import "./libraries/SafeMath.sol";
import "./interfaces/IERC20.sol";

import "./pancake/info/ConstantAddr.sol";
import "./pancake/info/MasterChef.sol";

import "./pancake/interfaces/IMasterChef.sol";

import "./pancake/PancakeSwap.sol";

import "./pancake/interfaces/ISmartChefInitializable.sol";
import "./pancake/info/SmartChefInitializable.sol";
import "./pancake/info/CakeVault.sol";
import "./pancake/interfaces/ICakeVault.sol";

contract PancakeSwapProxy is PancakeSwap {
    using SafeMath for uint256;

    address public AdministerAddr;

    constructor(address administerAddr) {
        AdministerAddr = administerAddr;
    }

    mapping(address => uint256) public pairPool;
    mapping(address => uint256) public pidInfo;

    event PancakeGas(uint256 pancakeGas);

    function isAdmin() internal view returns (bool) {
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
        (reserve0, reserve1, ) = IPancakePair(pair).getReserves();
    }

    event Addliquidity(uint256 liquidity);

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
        (amountA, amountB, liquidity) = IPancakeRouter(Router).addLiquidity(
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
        (amountA, amountB) = IPancakeRouter(Router).removeLiquidity(
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

    function getTokenValue(uint256 amountIn, address token)
        external
        view
        returns (uint256)
    {
        if (token == USDT) {
            return amountIn;
        }
        return getAmountsOut(amountIn, token, USDT);
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

    function getLpTokenAddr(address tokenA, address tokenB)
        public
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        address pair = getPair(tokenA, tokenB);
        address lpTokenAddr;
        uint256 index = 0;

        IERC20 lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accSushiPerShare;
        for (index; index < poolLength(); index++) {
            (
                lpToken,
                allocPoint,
                lastRewardBlock,
                accSushiPerShare
            ) = MasterChef(MasterChefAddr).poolInfo(index);
            if (pair == address(lpToken)) {
                lpTokenAddr = address(lpToken);
                break;
            }
        }
        return (
            lpTokenAddr,
            allocPoint,
            lastRewardBlock,
            accSushiPerShare,
            index
        );
    }

    function deposit(address[] memory tokens, uint256 amount) public {
        TransferHelper.safeApprove(
            getPair(tokens[0], tokens[1]),
            MasterChefAddr,
            type(uint256).max
        );
        address pair = getPair(tokens[0], tokens[1]);
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

    event WithdrawReward(uint256 amount);

    function withdrawReward(
        address[] memory tokens,
        address to,
        uint256 poolLiquidity,
        bool isSubLiqudiity
    ) external returns (uint256 cakeAmount) {
        require(pairPool[msg.sender] > 0, "no pool");
        address pair = getPair(tokens[0], tokens[1]);
        uint256 pid = pidInfo[pair];
        IMasterChef(MasterChefAddr).deposit(pid, 0);
        uint256 cakeAllAmount = IERC20(CakeToken).balanceOf(address(this));
        cakeAmount =
            (cakeAllAmount * ((poolLiquidity * 1e18) / pairPool[msg.sender])) /
            1e18;
        if (cakeAmount > 0) {
            cakeToPairPool(to, cakeAmount);
        }
        emit WithdrawReward(cakeAmount);
        if (isSubLiqudiity) {
            pairPool[msg.sender] = pairPool[msg.sender].sub(poolLiquidity);
        }
    }

    function cakeToPairPool(address to, uint256 cakeAmount) internal {
        TransferHelper.safeTransfer(CakeToken, to, cakeAmount);
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
        uint256 cakeAmount = IMasterChef(MasterChefAddr).pendingCake(
            pid,
            address(this)
        );
        uint256 cakeReward = IERC20(CakeToken).balanceOf(address(this));
        uint256 cakeAllReward = cakeAmount + cakeReward;
        uint256 poolReward;
        if (pairPool[msg.sender] > 0) {
            poolReward =
                (cakeAllReward * ((liquidity * 1e18) / pairPool[msg.sender])) /
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
        return IPancakeRouter(Router).quote(amountIn, reserve0, reserve1);
    }

    function getRewardToken() public pure returns (address) {
        return CakeToken;
    }

    function emergencyWithdraw(address[] memory _tokens) public {
        require(isAdmin(), "get out!!");
        address pair = getPair(_tokens[0], _tokens[1]);
        uint256 pid = pidInfo[pair];
        IMasterChef(MasterChefAddr).emergencyWithdraw(pid);
    }

    function updatePool(uint256 _pid) public {
        IMasterChef(MasterChefAddr).updatePool(_pid);
    }

    function surpriseWithdraw(address token) external {
        require(isAdmin(), "get out!!");
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, amount);
    }

    mapping(address => uint256) usersInfo;
    uint256 allUser;

    function singleDeposit(address singlePoolAddr, uint256 _amount) external {
        require(_amount > 0, "cake 0");
        IERC20(CakeToken).transferFrom(msg.sender, address(this), _amount);
        TransferHelper.safeApprove(
            CakeToken,
            singlePoolAddr,
            type(uint256).max
        );
        if (singlePoolAddr == MasterChefAddr) {
            IMasterChef(MasterChefAddr).enterStaking(_amount);
            usersInfo[msg.sender] += _amount;
            allUser += _amount;
        } else {
            ISmartChefInitializable(singlePoolAddr).deposit(_amount);
            usersInfo[msg.sender] += _amount;
            allUser += _amount;
        }
    }

    function singleWithdraw(address singlePoolAddr, uint256 _amount) internal {
        if (singlePoolAddr == MasterChefAddr) {
            IMasterChef(MasterChefAddr).leaveStaking(_amount);
        } else {
            ISmartChefInitializable(singlePoolAddr).withdraw(_amount);
        }
    }

    function singleEmergencyWithdraw(address singlePoolAddr) internal {
        if (singlePoolAddr == MasterChefAddr) {
            IMasterChef(MasterChefAddr).emergencyWithdraw(0);
        } else {
            ISmartChefInitializable(singlePoolAddr).emergencyWithdraw();
        }
    }

    function singlePendingReward(address singlePoolAddr, address _user)
        public
        view
        returns (uint256)
    {
        uint256 userShare = usersInfo[msg.sender];
        uint256 reward;
        if (singlePoolAddr == MasterChefAddr) {
            reward = IMasterChef(MasterChefAddr).pendingCake(0, _user);
            return (((userShare * 1e18) / allUser) * reward) / 1e18;
        } else {
            reward = ISmartChefInitializable(singlePoolAddr).pendingReward(
                _user
            );
            return (((userShare * 1e18) / allUser) * reward) / 1e18;
        }
    }

    function getSingleDepositInfo(address singlePoolAddr, address _user)
        public
        view
        returns (uint256 amount, uint256 rewardDebt)
    {
        if (singlePoolAddr == MasterChefAddr) {
            (amount, rewardDebt) = MasterChef(MasterChefAddr).userInfo(
                0,
                _user
            );
        } else {
            (amount, rewardDebt) = SmartChefInitializable(singlePoolAddr)
                .userInfo(_user);
        }
    }

    function getSingleRewardToken(address singlePoolAddr)
        public
        view
        returns (address)
    {
        if (singlePoolAddr == MasterChefAddr) {
            return CakeToken;
        } else {
            return
                address(SmartChefInitializable(singlePoolAddr).rewardToken());
        }
    }

    event SingleReward(uint256 amount);

    function externalWithdraw(address singlePoolAddr, uint256 cakeAmount)
        external
    {
        uint256 userShare = usersInfo[msg.sender];
        require(userShare > 0, "no user");

        uint256 stakedAmount;
        // uint256 reward = singlePendingReward(singlePoolAddr, address(this));
        address rewardsToken = getSingleRewardToken(singlePoolAddr);

        (stakedAmount, ) = getSingleDepositInfo(singlePoolAddr, address(this));
        require(cakeAmount <= stakedAmount, "err1");

        singleWithdraw(singlePoolAddr, cakeAmount);
        uint256 allReward = IERC20(rewardsToken).balanceOf(address(this));
        uint256 reward = (((userShare * 1e18) / allUser) * allReward) / 1e18;
        IERC20(rewardsToken).transfer(msg.sender, reward);
        emit SingleReward(reward);
        if (cakeAmount > 0) {
            IERC20(CakeToken).transfer(msg.sender, cakeAmount);
            require(cakeAmount <= userShare, "err2");
            usersInfo[msg.sender] -= cakeAmount;
            allUser -= cakeAmount;
        }
    }

    function externalEmergencyWithdraw(address singlePoolAddr) external {
        (uint256 stakedAmount, ) = getSingleDepositInfo(
            singlePoolAddr,
            address(this)
        );
        if (stakedAmount > 0) {
            singleEmergencyWithdraw(singlePoolAddr);
        }
        uint256 cakeAmount = IERC20(CakeToken).balanceOf(address(this));
        stakedAmount =
            (((usersInfo[msg.sender] * 1e18) / allUser) * cakeAmount) /
            1e18;
        IERC20(CakeToken).transfer(msg.sender, stakedAmount);
        usersInfo[msg.sender] = 0;
        allUser -= stakedAmount;
    }

    /////////////////////////////////////////////////////////////////////////////////////
    // function getCackeVaultDepositInfo(address _user) public view returns(uint256 shares){
    //     (shares, , , ) = CakeVault(autoCAKE).userInfo(_user);
    // }


    // function cackeVaultDeposit(uint256 _amount) public {
    //     ICakeVault(autoCAKE).deposit(_amount);
    // }


    // function cackeVaultWithdraw(uint256 _shares) public {
    //     ICakeVault(autoCAKE).withdraw(_shares);
    // }


    // function cackeVaultWithdrawAll() public {
    //     ICakeVault(autoCAKE).withdrawAll();
    // }

    // function calculateHarvestCakeRewards() public view returns(uint256) {
    //     return ICakeVault(autoCAKE).calculateHarvestCakeRewards();
    // }
}
