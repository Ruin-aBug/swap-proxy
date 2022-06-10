const { ethers, deployments, getNamedAccounts, getChainId } = require('hardhat');
const bigNumber = require("bignumber.js")

const { moduleExcute, getNetWorkName } = require("../deploy/tool");
let addressConfJson;
let tokens;

const timestamp = Math.ceil(new Date().getTime() / 1000)

describe("PancakeSwapProxy contract", function () {
  it("Test PancakeSwapProxy function", async function () {
    const chainId = await getChainId();
    const network = getNetWorkName(chainId);
    addressConfJson = require(`../conf/address-${network}.json`) // 以太坊测试网部署地址
    tokens = require(`./tokensAddr/tokens-${network}.json`); // 以太坊测试网币地址
    const { deployer } = await getNamedAccounts;
    const PancakeProxy = await deployments.get("PancakeSwapProxy");
    const pancakeProxy = await ethers.getContractAt(PancakeProxy.abi,PancakeProxy.address,deployer);
    console.log("proxy 合约地址 ", pancakeProxy.address);

    // console.log(await pancakeProxy.Router());
    // await add(pancakeProxy);
    // await getPair(pancakeProxy);

    // await addLiquidity(pancakeProxy)
    // await swapExactTokensForTokens(pancakeProxy)
    // await deposit(pancakeProxy);
    // await withdraw(pancakeProxy);
    // await removeLiquidity(pancakeProxy)
    // await withdrawReward(pancakeProxy)

    // await swap(pancakeProxy);
    // await getRemoveLiquidity(pancakeProxy)
    // await getPid(pancakeProxy); 			// 获取 pid
    // await setPid(pancakeProxy)
    //   await getPoolId(pancakeProxy);			// 只是获取 pid
    // await getDepositInfo(pancakeProxy); 	// 查询挖矿信息
    // await getRewards(pancakeProxy);       //查询挖矿收益

    // await allLiquidity(pancakeProxy)
    // await getRewardToken(pancakeProxy); 	// 查询收益币
    // await poolLength(pancakeProxy);		// 获取池子总长度
    // await getPair(pancakeProxy) // 获取 pair 地址
    // await getPancakeFactory(pancakeProxy); 	// 获取工厂合约地址
    // await getReserves(pancakeProxy); 		// 获取储备量

    // await getAmountsOut(pancakeProxy)      // 通过tokenA查询tokenB的个数
    // await getAmountsIn(pancakeProxy) 		//通过tokenB查询tokenA的个数
    // await getAmountOutForAmountIn(pancakeProxy)

    // await poolInfo(pancakeProxy) 			// 抵押池信息
    // await getLpTokenAddr(pancakeProxy); 	// 抵押池信息和 pid
    // await getTokenValue(pancakeProxy)      // 获取 token 对 U 的量
    // await testWithdraw(pancakeProxy);
    // await emergencyWithdraw(pancakeProxy);

    // 单币   单币   单币
    // await singleDeposit(pancakeProxy);
    // await getSingleDepositInfo(pancakeProxy);
    // await singlePendingReward(pancakeProxy)
    // await externalWithdraw(pancakeProxy);

    //   await updatePool(pancakeProxy) // 更新矿池，保证 cake 收益是最新的
    // await getAllPath(pancakeProxy);
    // await getOptimalOut(pancakeProxy)
    // await getOptimalIn(pancakeProxy);
    // await getOutValue(pancakeProxy);

    // await pairPool(pancakeProxy);
  });

  async function pairPool(pancakeProxy) {
    const res = await pancakeProxy.pairPool(
      "0x4457ac90bcf438b8F5D4F6540601106135D8367E",
    )
    console.log(res.toString())
  }

  async function singleDeposit(pancakeProxy) {
    const res = await pancakeProxy.singleDeposit(
      "0xeBCa80F9Fd447c4c8e1591F07402506665f3ca31",
      new bigNumber("100000000000000000000"),
    )
    console.log(res)
  }

  async function getSingleDepositInfo(pancakeProxy) {
    const res = await pancakeProxy.getSingleDepositInfo(
      "0xeBCa80F9Fd447c4c8e1591F07402506665f3ca31",
      addressConfJson.pancakeProxy,
    )
    console.log(res[0].toString())
    console.log(res[1].toString())
  }

  async function singlePendingReward(pancakeProxy) {
    const res = await pancakeProxy.singlePendingReward(
      "0xeBCa80F9Fd447c4c8e1591F07402506665f3ca31",
      addressConfJson.pancakeProxy,
    )
    console.log(res.toString())
  }

  async function externalWithdraw(pancakeProxy) {
    const res = await pancakeProxy.externalWithdraw(
      "0xeBCa80F9Fd447c4c8e1591F07402506665f3ca31",
      new bigNumber("100000000000000000000"),
    )
    console.log(res)
  }

  async function emergencyWithdraw(pancakeProxy) {
    const res = await pancakeProxy.emergencyWithdraw([tokens.BTCB, tokens.BUSD])
    console.log(res)
  }

  async function getAllPath(pancakeProxy) {
    let res = await pancakeProxy.getAllPath(tokens.ETH, tokens.BUSD)
    console.log(res)
  }

  async function getOptimalOut(pancakeProxy) {
    let res = await pancakeProxy.getOptimalOut(
      tokens.CAKE,
      tokens.USDT,
      new bigNumber("1000000000000000000"),
    )
    // console.log(res[0])
    console.log(res[1].toString())
  }

  async function getOptimalIn(pancakeProxy) {
    let res = await pancakeProxy.getOptimalIn(
      tokens.USDT,
      tokens.ETH,
      new bigNumber("5824183825036618"),
    )
    console.log(res[1].toString())
  }

  async function getOutValue(pancakeProxy) {
    let res = await pancakeProxy.getOutValue(
      [tokens.USDT, tokens.BTCB, tokens.BUSD],
      new bigNumber(1).times(1e18),
    )
    console.log(res.toString())
  }

  async function add(pancakeProxy) {
    const sushiAdd = await pancakeProxy.add(
      new bigNumber(1).times(1e18),
      "",
      true,
    )
    console.log(sushiAdd)
  }

  async function addLiquidity(pancakeProxy) {
    const amountA = new bigNumber("1000000000000000000000000000")
    const amountB = await pancakeProxy.getAmountOutForAmountIn(
      tokens.USDT,
      tokens.ETH,
      0,
      0,
      0,
      amountA,
    )
    // 添加流动性
    const liquidity = await pancakeProxy.addLiquidity0(
      [tokens.CAKE, tokens.USDT],
      [
        new bigNumber("11310955000000000000000000"),
        new bigNumber("180975280000000000000000000"),
      ],
      0,
      timestamp + 300,
    )
    console.log(liquidity)
  }

  async function withdrawReward(pancakeProxy) {
    // 移除挖矿
    const withd = await pancakeProxy.withdrawReward(
      [tokens.XRK, tokens.SZCY],
      addressConfJson.admin,
      new bigNumber(1775),
    )
    console.log(withd.toString())
  }

  async function removeLiquidity(pancakeProxy) {
    // 移除流动性
    const remove = await pancakeProxy.removeLiquidity(
      [tokens.USDT, tokens.ETH],
      0,
      addressConfJson.admin,
      new bigNumber("18257409454793963183998740"),
      timestamp + 300,
    )
    console.log(remove)
  }

  async function deposit(pancakeProxy) {
    const res = await pancakeProxy.deposit(
      [tokens.USDT, tokens.ETH],
      new bigNumber("18257409454793963183998740"),
    )
    console.log(res)
  }

  async function withdraw(pancakeProxy) {
    const withd = await pancakeProxy.withdraw(
      [tokens.USDT, tokens.ETH],
      new bigNumber("1825740945479396318399874"),
    )
    console.log(withd)
  }

  async function swapExactTokensForTokens(pancakeProxy) {
    // 换币函数
    const swap = await pancakeProxy.swapExactTokensForTokens(
      new bigNumber("6666000000000000000000"),
      0,
      [tokens.ETH, tokens.USDT],
      addressConfJson.admin,
      timestamp + 300,
    )
    console.log(swap)
  }

  async function setPid(pancakeProxy) {
    let tokenA = tokens.BTCB
    let tokenB = tokens.BUSD
    const pair = await pancakeProxy.getPair(tokenA, tokenB)
    const pid = await pancakeProxy.getPid(tokenA, tokenB)
    console.log("pair地址：", pair)
    console.log("pid:", pid.toNumber())
    const res = await pancakeProxy.setPidInfo(pair, pid)
    console.log(res)
  }

  async function getPoolId(pancakeProxy) {
    // 只是获取 pid
    const pid = await pancakeProxy.getPoolId(tokens.UNI, tokens.WETH)
    console.log("获取传入币对的 pid:", pid.toString())
  }

  async function getDepositInfo(pancakeProxy) {
    const to = addressConfJson.pancakeProxy
    const info = await pancakeProxy.getDepositInfo(
      tokens.USDT,
      tokens.ETH,
      addressConfJson.pancakeProxy,
    )
    console.log("查询挖矿信息 lpToken数量：", info[0].toString())
    console.log("查询挖矿信息：", info[1].toString())
  }

  async function getRewards(pancakeProxy) {
    const sushi = await pancakeProxy.getRewards(
      [tokens.ETH, tokens.USDT],
      new bigNumber(0),
    )
    console.log("收益：", sushi.toString())
  }

  async function allLiquidity(pancakeProxy) {
    const sushi = await pancakeProxy.allLiquidity()
    console.log("流动性总量：", sushi.toString())
  }

  async function getRewardToken(pancakeProxy) {
    const sushi = await pancakeProxy.getRewardToken()
    console.log("查询挖矿的收益币：", sushi.toString())
  }

  async function addPairAddrOFPid(pancakeProxy) {
    const pair = ""
    await pancakeProxy.addPairAddrOFPid(pair, pid)
  }

  async function poolLength(pancakeProxy) {
    const len = await pancakeProxy.poolLength()
    console.log("获取池子总长度：", len.toString())
  }

  async function getPid(pancakeProxy) {
    const pair = "0xF45cd219aEF8618A92BAa7aD848364a158a24F33"
    const poll = await pancakeProxy.pidInfo(pair)
    console.log("pari:pid", poll.toString())
  }

  async function getPair(pancakeProxy) {
    const btcb = tokens.BTCB
    const busd = tokens.BUSD
    const pair = await pancakeProxy.getPair(btcb, busd)
    console.log("获取pair地址：", pair)
    // console.log(await pancakeProxy.pidInfo(pair))
  }

  async function getPancakeFactory(pancakeProxy) {
    const f = await pancakeProxy.getPancakeFactory()
    console.log("获取 pancakeswap 的工厂合约地址：", f.toString())
  }

  async function getReserves(pancakeProxy) {
    const tokenA = tokens.USDT
    const tokenB = tokens.ETH
    const re = await pancakeProxy.getReserves(tokenA, tokenB)
    console.log("获取储备量：", re[0].toString())
    console.log("获取储备量：", re[1].toString())
  }

  async function getAmountsOut(pancakeProxy) {
    const amountIn = new bigNumber(1).times(1e18)
    const tokenA = tokens.BTCB
    const tokenB = tokens.BUSD
    const amountB = await pancakeProxy.getAmountsOut(amountIn, tokenA, tokenB)
    console.log("通过tokenA查询tokenB的个数:", amountB)
  }

  async function getAmountsIn(pancakeProxy) {
    const amountOut = new bigNumber(1).times(1e18)
    const tokenB = tokens.SZCY
    const tokenA = tokens.XRK
    const outA = await pancakeProxy.getAmountsIn(amountOut, tokenA, tokenB)
    console.log("通过tokenB查询tokenA的个数:", outA.toString())
  }

  async function getAmountOutForAmountIn(pancakeProxy) {
    let amountA = new bigNumber("2000000000000000000")
    const amountB = await pancakeProxy.getAmountOutForAmountIn(
      tokens.USDT,
      tokens.ETH,
      0,
      0,
      0,
      amountA,
    )
    console.log(amountB.toString())
  }

  async function getRemoveLiquidity(pancakeProxy) {
    let amounts = await pancakeProxy.getRemoveLiquidity(
      [tokens.ETH, tokens.USDT],
      new bigNumber("29507418238262113"),
      0,
    )
    console.log(amounts[0].toString())
    console.log(amounts[1].toString())
  }

  async function getLpTokenAddr(pancakeProxy) {
    const tokenB = tokens.XRK
    const tokenA = tokens.SZCY
    const pidInfos = await pancakeProxy.getLpTokenAddr(tokenA, tokenB)
    console.log("挖矿池子的信息--lpToken--地址: ", pidInfos[0].toString())
    console.log("挖矿池子的信息：-------------: ", pidInfos[1].toString())
    console.log("挖矿池子的信息：-------------: ", pidInfos[2].toString())
    console.log("挖矿池子的信息：-------------: ", pidInfos[3].toString())
    console.log("挖矿池子的信息--pid----------: ", pidInfos[4].toString())
  }

  async function getTokenValue(pancakeProxy) {
    const token = tokens.XRK
    const amountIn = new bigNumber(1).times(1e18)
    const tokenUSDT = await pancakeProxy.getTokenValue(amountIn, token)
    console.log("获取 1 个 token 对USDT的个数: ", tokenUSDT.toString())
  }

  async function testWithdraw(pancakeProxy) {
    // await pancakeProxy.testWithdraw(tokens.USDT)
    await pancakeProxy.testWithdraw("0xF45cd219aEF8618A92BAa7aD848364a158a24F33")
    // await pancakeProxy.testWithdraw(tokens.BTCB)
  }

  async function swap(pancakeProxy) {
    const swape = await pancakeProxy.swapExactTokensForTokens(
      new bigNumber(2500000).times(1e18),
      0,
      ["0x2AD77149508F47eC21543feD58c627CA793FacC9", tokens.XRK],
      addressConfJson.admin,
      timestamp + 3000,
    )
    console.log(swape)
  }

  async function updatePool(pancakeProxy) {
    const pid = 1
    await pancakeProxy.updatePool(pid)
  }
});
