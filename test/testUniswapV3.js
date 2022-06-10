const { ethers, deployments, getNamedAccounts, getChainId } = require('hardhat');
const bigNumber = require("bignumber.js")

const { moduleExcute, getNetWorkName } = require("../deploy/tool");
let addressConfJson;
let tokens;

const timestamp = Math.ceil(new Date().getTime() / 1000)

describe("UniSwapV3Proxy contract", function () {
  it("Test UniSwapV3Proxy function", async function () {
    const chainId = await getChainId();
    const network = getNetWorkName(chainId);
    addressConfJson = require(`../conf/address-${network}.json`) // 以太坊测试网部署地址
    tokens = require(`./tokensAddr/tokens-${network}.json`); // 以太坊测试网币地址
    const { deployer } = await getNamedAccounts;
    const UniswapV3Proxy = await deployments.get("UniswapV3Proxy");
    const univ3 = await ethers.getContractAt(UniswapV3Proxy.abi, UniswapV3Proxy.address, deployer);
    console.log("proxy 合约地址 ", univ3.address);

    // await getTokenValue(univ3);
    // await removeLiquidity(univ3);
    // await getAmountsForLiquidity(univ3)
    // await getPoolSlot(univ3);
    // await positions(univ3)
    // await getAmountInForAmountOut(univ3);
  });

  async function getTokenValue(univ3) {
    let res = await univ3.getTokenValue(
      new bigNumber(1).times(1e18),
      tokens.SZCY,
    )
    console.log(res)
  }

  async function removeLiquidity(univ3) {
    let res = await univ3.removeLiquidity(
      [tokens.XRK, tokens.SZCY],
      4176,
      addressConfJson.admin,
      new bigNumber(201573385861360542084),
      timestamp + 3000,
    )
  }

  async function decreaseLiquidity(univ3) {
    let res = await univ3.decreaseLiquidity()
  }

  async function positions(univ3) {
    let res = await univ3.positions(4176)
    console.log(res[7].toString())
  }

  async function getAmountsForLiquidity(univ3) {
    let amounts = await univ3.getAmountsForLiquidity(
      tokens.XRK,
      tokens.SZCY,
      new bigNumber(1000),
      4105,
    )
    console.log(amounts[0])
    console.log(amounts[1])
  }

  async function getPoolSlot(univ3) {
    let res = await univ3.getPoolSlot(tokens.XRK, tokens.SZCY, 3000)
    console.log(res[0])
  }

  async function getAmountInForAmountOut(univ3) {
    let amountIn = await getAmountInForAmountOut(
      tokens.XRK,
      tokens.SZCY,
      3000,
      -17940,
      92100,
      new bigNumber(1000),
    )

    console.log(amountIn.toString())
  }
});