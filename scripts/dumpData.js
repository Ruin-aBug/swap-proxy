const argv = require("yargs")
  .demandOption(
    ["network", "pid"],
    "Please provide [network] [pid] argument to work with me",
  )
  .epilog("copyright 2021 rainbow dump tools").argv
const clientDirectory =
  "/Users/ewonder/Documents/workspace/blockchain/rainbowClient"
const tokens = require(`${clientDirectory}/public/data/tokens`)

// console.log(tokens);

const { getDpNumber, chainData } = require("./module/utils")
const {
  initChainTokens,
  getTokenDecimal,
  getTokenName,
} = require("./module/tokenHelpers")
const {
  moduleRun,
  getUseNetworkName,
  upStrFirstChar,
} = require("../migrations/tools")
const BigNumber = require("bignumber.js")

module.exports = async (callback) => {
  await moduleRun(argv.network, run)
  callback()
}

async function run(jsonConf, confFileName, network) {
  const chainId = chainData[network.toLowerCase()]
  initChainTokens(tokens, chainId)

  // console.log(getTokenDecimal(tokens, 'uni', chainId));

  const tableData = []
  let networkName = upStrFirstChar(network.toLowerCase())
  networkName = getUseNetworkName(networkName)

  tableData.push(["confFileName", confFileName])
  tableData.push(["network", network])
  tableData.push(["network name", networkName])

  const rainbowInst = artifacts.require(`${networkName}Rainbow`)
  const rainbow = await rainbowInst.at(jsonConf.rainbow)
  tableData.push(["rainbow地址", rainbow.address])

  const pid = argv.pid
  tableData.push(["pid", pid])
  const poolAddress = await rainbow.getPoolAddress(pid)
  tableData.push([`pid_${pid}_address`, poolAddress])

  console.log(`\n\n基本信息:`)
  console.table(tableData)

  if (argv.user) {
    await this.logUser(rainbow, argv.user.toString(), pid)
  }

  const poolDataList = await rainbow.getAllPoolInfo()
  const totalCount = poolDataList.length
  for (let index = totalCount - 1; index >= 0; index--) {
    const poolData = poolDataList[index]
    const id = poolData.poolId
    if (id == pid) {
      await this.logPool(rainbow, poolData, chainId)
    }
  }
}

async function logPool(rainbow, poolData, chainId) {
  const tableData = []

  let positionData = 0
  if (
    (poolData[4][0] != "0" && poolData[4][0] != 0) ||
    (poolData[4][1] != "0" && poolData[4][1] != 0)
  ) {
    console.log([poolData[4][0] == 0 ? 1 : poolData[4][0], poolData[4][1]])
    // positionData = await rainbow.getTotalValue(poolData.id, [poolData[4][0] == 0 ? 1 : poolData[4][0], poolData[4][1]]);
  }

  const token1Addresss = poolData[3][0]
  console.log(token1Addresss)
  const token2Addresss = poolData[3][1]
  const bigAmount1 = new BigNumber(poolData[1][0])
  const bitAmount2 = new BigNumber(poolData[1][1])
  const decimal1 = getTokenDecimal(tokens, token1Addresss.toString(), chainId)
  const decimal2 = getTokenDecimal(tokens, token2Addresss, chainId)
  tableData.push([
    "token1",
    getTokenName(token1Addresss, chainId),
    decimal1,
    token1Addresss,
  ])
  tableData.push([
    "token2",
    getTokenName(token2Addresss, chainId),
    decimal2,
    token2Addresss,
  ])
  tableData.push([
    "amount1",
    bigAmount1.toString(),
    getDpNumber(bigAmount1, decimal1, 8, false),
  ])
  tableData.push([
    "amount2",
    bitAmount2.toString(),
    getDpNumber(bitAmount2, decimal2, 8, false),
  ])
  // tableData.push(['lockPosition', positionData.toString(), getDpNumber(positionData, getTokenDecimal(tokens, 'usdt', chainId), 8, false)]);

  console.log(`\n\npool(pid_${poolData.id})相关信息:`)
  console.table(tableData)
}

async function logUser(rainbow, lpAddr, pid) {
  const strUser = `0x${lpAddr}`
  // console.log(strUser);
  const user = await rainbow.userInfo(pid, strUser)
  const tableData = []
  // const decimalA = getTokenDecimal(tokens, 'uni', chainId)
  tableData.push([
    "updateamountA:",
    user[1].toString(),
    getDpNumber(user[1], 18, 8),
  ])
  tableData.push(["amountA:", user[0].toString(), getDpNumber(user[0], 18, 8)])
  tableData.push(["amountB:", user[2].toString(), getDpNumber(user[2], 18, 8)])
  tableData.push([
    "updateamountB:",
    user[3].toString(),
    getDpNumber(user[3], 18, 8),
  ])
  tableData.push([
    "liquidity:",
    user[4].toString(),
    getDpNumber(user[4], 18, 8),
  ])
  tableData.push(["reward:", user[5].toString(), getDpNumber(user[5], 18, 8)])

  console.log(`\n\n用户(${lpAddr})相关信息:`)
  console.table(tableData)
}
