const { ethers, deployments, getNamedAccounts,getChainId} = require('hardhat');
const bigNumber = require("bignumber.js")

const { moduleExcute, getNetWorkName } = require("../deploy/tool");
let addressConfJson;
let tokens;

const timestamp = Math.ceil(new Date().getTime() / 1000)

describe("SuShiSwapProxy contract", function () {
  it("Test SuShiSwapProxy function", async function () {
    const chainId = await getChainId();
    const network = getNetWorkName(chainId);
    addressConfJson = require(`../conf/address-${network}.json`); // 以太坊测试网部署地址
    tokens = require(`./tokensAddr/tokens-${network}.json`); // 以太坊测试网币地址
    const { deployer } = await getNamedAccounts;
    const SuShiProxy = await deployments.get("SuShiSwapProxy");
    
    const sushiProxy = await ethers.getContractAt(SuShiProxy.abi,SuShiProxy.address,deployer);
    console.log("proxy 合约地址 ", sushiProxy.address);
    // await add(sushiProxy);
    // await getPair(sushiProxy);

    // await addLiquidity(sushiProxy);
    // await swapExactTokensForTokens(sushiProxy);
    // await withdraw(sushiProxy);
    //   await removeLiquidity(sushiProxy)
    // await withdrawReward(sushiProxy)

    // await swap(sushiProxy)
    // await getRemoveLiquidity(sushiProxy)
    // await getPid(sushiProxy) // 获取 pid
    // await setPid(sushiProxy)
    // await getPoolId(sushiProxy);			// 只是获取 pid
    // await getDepositInfo(sushiProxy); 	// 查询挖矿信息
    // await getRewards(sushiProxy) //查询挖矿收益
    // await getRewardToken(sushiProxy); 	// 查询收益币
    // await poolLength(sushiProxy);		// 获取池子总长度
    // await getPair(sushiProxy);  			// 获取 pair 地址
    // await getSuShiFactory(sushiProxy); 	// 获取工厂合约地址
    // await getReserves(sushiProxy); 		// 获取储备量
    // await getAmountsOut(sushiProxy) // 通过tokenA查询tokenB的个数
    // await getAmountsIn(sushiProxy) 		//通过tokenB查询tokenA的个数
    // await getAmountOutForAmountIn(sushiProxy)
    // await getAmountInForAmountOut(sushiProxy)
    // await poolInfo(sushiProxy) 			// 抵押池信息
    // await getLpTokenAddr(sushiProxy); 	// 抵押池信息和 pid
    // await getTokenValue(sushiProxy) // 获取 token 对 U 的量
    // await testWithdraw(sushiProxy);
    // await pairPool(sushiProxy)
    // await poolLiquidity(sushiProxy);

    // await getAllPath(sushiProxy);
    // await getOptimalOut(sushiProxy)
    // await getOutValue(sushiProxy);

    // await getOptimalIn(sushiProxy)
    // await getInValue(sushiProxy);
  });

  async function getAllPath(sushiProxy) {
    let res = await sushiProxy.getAllPath(tokens.ETH, tokens.USDT)
    console.log(res)
  }

  async function getOptimalOut(sushiProxy) {
    let res = await sushiProxy.getOptimalOut(
      tokens.USDT,
      tokens.SUSHI,
      new bigNumber("1000000000000000000"),
    )
    console.log(res[0])
    console.log(res[1].toString())
  }

  async function getOptimalIn(sushiProxy) {
    let res = await sushiProxy.getOptimalIn(
      tokens.SUSHI,
      tokens.ETH,
      new bigNumber("11568992501101329972"),
    )
    console.log(res[0])
    console.log(res[1].toString())
  }

  async function getOutValue(sushiProxy) {
    let res = await sushiProxy.getOutValue(
      [tokens.ETH, tokens.USDT],
      new bigNumber("1000000000000000000"),
    )
    console.log(res.toString())
  }

  async function getInValue(sushiProxy) {
    let res = await sushiProxy.getInValue(
      [tokens.ETH, tokens.USDT, tokens.SUSHI],
      new bigNumber("509209173"),
    )
    console.log(res.toString())
  }

  async function poolLiquidity(sushiProxy) {
    let pool = await sushiProxy.poolLiquidity()
    let lp = await sushiProxy.reLiquidity()
    console.log(pool.toString())
    console.log(lp.toString())
  }

  async function pairPool(sushiProxy) {
    const res = await sushiProxy.pairPool(addressConfJson.admin)
    console.log(res.toString())
  }

  async function add(sushiProxy) {
    const sushiAdd = await sushiProxy.add(new bigNumber(1).times(1e18), "", true)
    console.log(sushiAdd)
  }

  async function addLiquidity(sushiProxy) {
    const amountB = await sushiProxy.getAmountOutForAmountIn(
      tokens.XRK,
      tokens.SZCY,
      0,
      0,
      0,
      new bigNumber(5).times(1e18),
    )
    // 添加流动性
    const liquidity = await sushiProxy.addLiquidity(
      [tokens.XRK, tokens.SZCY],
      [new bigNumber(5).times(1e18), amountB],
      0,
      timestamp + 300,
    )
    console.log(liquidity)
  }

  async function withdrawReward(sushiProxy) {
    // 移除挖矿
    const withd = await sushiProxy.withdrawReward(
      [tokens.XRK, tokens.SZCY],
      addressConfJson.admin,
      new bigNumber(1775),
    )
    console.log(withd.toString())
  }

  async function removeLiquidity(sushiProxy) {
    // 移除流动性
    const remove = await sushiProxy.removeLiquidity(
      [tokens.XRK, tokens.SZCY],
      0,
      addressConfJson.admin,
      new bigNumber(3),
      timestamp + 300,
    )
    console.log(remove)
  }

  async function withdraw(sushiProxy) {
    const withd = await sushiProxy.withdraw(
      [tokens.XRK, tokens.SZCY],
      new bigNumber(3039555389478364642),
    )
    console.log(withd)
  }

  async function swapExactTokensForTokens(sushiProxy) {
    // 换币函数
    const swap = await sushiProxy.swapExactTokensForTokens(
      new bigNumber(0).times(1e18),
      0,
      [tokens.ETH, tokens.USDT],
      addressConfJson.admin,
      timestamp + 300,
    )
    console.log(swap)
  }

  async function getPid(sushiProxy) {
    // 设置 pair => 对应 pid 并且将交易所的 pid
    const pid = await sushiProxy.getPid(tokens.ETH, tokens.USDT)
    console.log("pair 的 pid:", pid.toString())
  }

  async function setPid(sushiProxy) {
    const pair = await sushiProxy.getPair(tokens.ETH, tokens.USDT);
    const pid = await sushiProxy.getPid(tokens.ETH, tokens.USDT);
    console.log(pair, "\n", pid.toString());
    const res = await sushiProxy.setPidInfo(pair, pid);
    console.log(res);
  }

  async function getPoolId(sushiProxy) {
    // 只是获取 pid
    const pid = await sushiProxy.getPoolId(tokens.UNI, tokens.WETH)
    console.log("获取传入币对的 pid:", pid.toString())
  }

  async function getDepositInfo(sushiProxy) {
    const to = addressConfJson.sushiProxy
    const info = await sushiProxy.getDepositInfo(
      tokens.SZCY,
      tokens.XRK,
      to,
    )
    console.log("查询挖矿信息 lpToken数量：", info[0].toString())
    console.log("查询挖矿信息：", info[1].toString())
  }

  async function getRewards(sushiProxy) {
    const sushi = await sushiProxy.getRewards(
      [tokens.USDT, tokens.ETH],
      new bigNumber("58536266360520598080"),
    )
    console.log("收益：", sushi.toString())
  }

  async function allLiquidity(sushiProxy) {
    const sushi = await sushiProxy.allLiquidity()
    console.log("流动性总量：", sushi.toString())
  }

  async function getRewardToken(sushiProxy) {
    const sushi = await sushiProxy.getRewardToken()
    console.log("查询挖矿的收益币：", sushi.toString())
  }

  async function addPairAddrOFPid(sushiProxy) {
    const pair = ""
    await sushiProxy.addPairAddrOFPid(pair, pid)
  }

  async function poolLength(sushiProxy) {
    const len = await sushiProxy.poolLength()
    console.log("获取池子总长度：", len.toString())
  }

  async function pidInfo(sushiProxy) {
    const pair = ""
    const poll = await sushiProxy.pidInfo(pair)
    console.log("pari:pid", poll.toString())
  }

  async function getPair(sushiProxy) {
    const tokenA = tokens.SUSHI
    const tokenB = tokens.USDT
    const pair = await sushiProxy.getPair(tokenA, tokenB)
    console.log("获取pair地址：", pair)
  }

  async function getSuShiFactory(sushiProxy) {
    const f = await sushiProxy.getSuShiFactory()
    console.log("获取sushiswap的工厂合约地址：", f.toString())
  }

  async function getReserves(sushiProxy) {
    const tokenA = tokens.WETH
    const tokenB = tokens.USDT
    const re = await sushiProxy.getReserves(tokenA, tokenB)
    console.log("获取储备量：", re[0].toString())
    console.log("获取储备量：", re[1].toString())
  }

  async function getAmountsOut(sushiProxy) {
    const amountIn = new bigNumber(1).times(1e18)
    const tokenA = tokens.XRK
    const tokenB = tokens.SZCY
    const amountB = await sushiProxy.getAmountsOut(amountIn, tokenA, tokenB)
    console.log("通过tokenA查询tokenB的个数:", amountB)
  }

  async function getAmountsIn(sushiProxy) {
    const amountOut = new bigNumber("2977706187040405950755")
    const tokenA = tokens.ETH
    const tokenB = tokens.USDT
    const outA = await sushiProxy.getAmountsIn(amountOut, tokenA, tokenB)
    console.log("通过tokenB查询tokenA的个数:", outA.toString())
  }

  async function getAmountOutForAmountIn(sushiProxy) {
    let amountA = new bigNumber("999999999999997395")
    const amountB = await sushiProxy.getAmountOutForAmountIn(
      tokens.ETH,
      tokens.USDT,
      0,
      0,
      0,
      amountA,
    )
    console.log(amountB.toString())
  }

  async function getAmountInForAmountOut(sushiProxy) {
    let amountB = new bigNumber("328125929838624")
    const amountA = await sushiProxy.getAmountInForAmountOut(
      tokens.ETH,
      tokens.USDT,
      0,
      0,
      0,
      amountB,
    )
    console.log(amountA.toString())
  }

  async function getRemoveLiquidity(sushiProxy) {
    let amounts = await sushiProxy.getRemoveLiquidity(
      [tokens.XRK, tokens.SZCY],
      new bigNumber("10"),
      0,
    )
    console.log(amounts[0].toString())
    console.log(amounts[1].toString())
  }

  async function getLpTokenAddr(sushiProxy) {
    const tokenB = tokens.XRK
    const tokenA = tokens.SZCY
    const pidInfos = await sushiProxy.getLpTokenAddr(tokenA, tokenB)
    console.log("挖矿池子的信息--lpToken--地址: ", pidInfos[0].toString())
    console.log("挖矿池子的信息：-------------: ", pidInfos[1].toString())
    console.log("挖矿池子的信息：-------------: ", pidInfos[2].toString())
    console.log("挖矿池子的信息：-------------: ", pidInfos[3].toString())
    console.log("挖矿池子的信息--pid----------: ", pidInfos[4].toString())
  }

  async function getTokenValue(sushiProxy) {
    const token = tokens.XRK
    const amountIn = new bigNumber(1).times(1e18)
    const tokenUSDT = await sushiProxy.getTokenValue(amountIn, tokens.SUSHI)
    console.log("获取 1 个 token 对USDT的个数: ", tokenUSDT.toString())
  }

  async function testWithdraw(sushiProxy) {
    const sushi = await sushiProxy.testWithdraw(tokens.SUSHI)
    await sushiProxy.testWithdraw(tokens.XRK)
    await sushiProxy.testWithdraw(tokens.SZCY)
  }

  async function swap(sushiProxy) {
    let amountIn = new bigNumber("1000000000000000000")
    const amountOut = await sushiProxy.getOptimalOut(
      tokens.ETH,
      tokens.USDT,
      amountIn,
    )
    const swape = await sushiProxy.swapExactTokensForTokens(
      amountIn,
      amountOut[1],
      amountOut[0],
      addressConfJson.admin,
      timestamp + 3000,
    )
    console.log(swape)
  }
});