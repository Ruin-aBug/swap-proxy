const { ethers, deployments, getNamedAccounts, getChainId } = require('hardhat');
const bigNumber = require("bignumber.js")

const { moduleExcute, getNetWorkName } = require("../deploy/tool");
let addressConfJson;
let tokens;

const timestamp = Math.ceil(new Date().getTime() / 1000)

describe("MdexSwapProxy contract", function () {
  it("Test MdexSwapProxy function", async function () {
    const chainId = await getChainId();
    const network = getNetWorkName(chainId);
    addressConfJson = require(`../conf/address-${network}.json`) // 以太坊测试网部署地址
    tokens = require(`./tokensAddr/tokens-${network}.json`); // 以太坊测试网币地址
    const { deployer } = await getNamedAccounts;
    const MdexProxy = await deployments.get("MdexHecoProxy");
    const mdexProxy = await ethers.getContractAt(MdexProxy.abi,MdexProxy.address,deployer);
    console.log("proxy 合约地址 ", mdexProxy.address);
    // console.log(await mdexProxy.getRouter())
    // await addLiquidity(mdexProxy)
    // await swapExactTokensForTokens(mdexProxy);
    // await withdraw(mdexProxy);
    //   await removeLiquidity(mdexProxy)
    // await getRemoveLiquidity(mdexProxy)

    // await getPair(mdexProxy)

    // await getAllPath(mdexProxy);
    // await getOptimalOut(mdexProxy)
    // await getOptimalIn(mdexProxy)
    // await getOutValue(mdexProxy)
    // await getInValue(mdexProxy);
    // await getValue(mdexProxy)
  });
  async function getAllPath(mdexProxy) {
    let res = await mdexProxy.getAllPath(tokens.BUSD, tokens.UNI)
    console.log(res)
  }

  async function getOptimalOut(mdexProxy) {
    let res = await mdexProxy.getOptimalOut(
      tokens.USDT,
      tokens.USDT,
      new bigNumber("10000000000000000000"),
    )
    console.log(res[0])
    console.log(res[1].toString())
  }

  async function getOptimalIn(mdexProxy) {
    let res = await mdexProxy.getOptimalIn(
      tokens.BUSD,
      tokens.UNI,
      new bigNumber("37609922190722528"),
    )
    console.log(res[0])
    console.log(res[1].toString())
  }

  async function getOutValue(mdexProxy) {
    let res = await mdexProxy.getOutValue(
      [tokens.WBNB, tokens.BUSD],
      new bigNumber("0"),
    )
    console.log(res.toString())
  }

  async function getInValue(mdexProxy) {
    let res = await mdexProxy.getInValue(
      [tokens.BUSD, tokens.USDT, tokens.UNI],
      new bigNumber("37609922190722528"),
    )
    console.log(res.toString())
  }

  async function getValue(mdexProxy) {
    let res = await mdexProxy.getValue(
      [tokens.MDX, tokens.UNI],
      new bigNumber(1).times(1e18),
    )
    console.log(res.toString())
  }

  async function addLiquidity(mdexProxy) {
    const liquidity = await mdexProxy.addLiquidity(
      [tokens.UNI, tokens.USDT],
      [new bigNumber(0.001).times(1e18), new bigNumber(0.019).times(1e18)],
      [0, 0],
      timestamp + 300,
    )
    console.log(
      "a,b,liquidity",
      liquidity[0].toNumber(),
      liquidity[1].toString(),
      liquidity[2].toString(),
    )
  }

  async function withdraw(mdexProxy) {
    const withd = await mdexProxy.withdraw(
      [tokens.UNI, tokens.USDT],
      addressConfJson.admin,
      new bigNumber(0.0002).times(1e18),
    )
    console.log(withd.toString())
  }

  async function removeLiquidity(mdexProxy) {
    const remove = await mdexProxy.removeLiquidity(
      [tokens.UNI, tokens.USDT],
      [0, 0],
      addressConfJson.admin,
      new bigNumber(0.0002).times(1e18),
      timestamp + 300,
    )
  }

  async function swapExactTokensForTokens(mdexProxy) {
    const swap = await mdexProxy.swapExactTokensForTokens(
      new bigNumber(0.001).times(1e18),
      0,
      [tokens.UNI, tokens.USDT],
      addressConfJson.admin,
      timestamp + 300,
    )
    console.log(swap[0].toString(), swap[1].toString())
  }

  async function getPair(mdexProxy) {
    const res = await mdexProxy.getPair(tokens.USDC, tokens.UNI)
    console.log(res)
  }

  async function getRemoveLiquidity(mdexProxy) {
    const tokenA = "0xBf5140A22578168FD562DCcF235E5D43A02ce9B1"
    const tokenB = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56"
    const token = [tokenA, tokenB]
    const liqutiy = new bigNumber("5273566097531983165")
    const tokenId = 0
    const info = await mdexProxy.getRemoveLiquidity(token, liqutiy, tokenId)
    console.log("币 A 的量: ", info[0].toString())
    console.log("币 B 的量: ", info[1].toString())
  }
});