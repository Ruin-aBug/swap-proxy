const BigNumber = require("bignumber.js")

function toHex(data, power = 18, rate = 0) {
  let x = new BigNumber(data + "")
  const powerNumber = new BigNumber(10).pow(power)
  if (rate > 0) {
    x = x.times(rate)
  }
  return "0x" + x.times(powerNumber).toString(16)
}

function getDpNumber(data, power = 18, index = 2, flag = false) {
  //data 需要处理的数据
  //power 1epower
  //index 保留精度
  //flag  是否是百分数处理
  let x = new BigNumber(data)
  if (flag == true) {
    x = x.times(100)
  }
  let powerNumber = new BigNumber(10).pow(power)
  return x.dividedBy(powerNumber).toFixed(index, 1)
}

function swapKeyValue(obj) {
  return Object.keys(obj).reduce(
    (r, key) => Object.assign(r, { [obj[key]]: key }),
    {},
  )
}

const chainData = {
  mainnet: 1,
  heco: 128,
  bsc: 56,
  rinkeby: 4,
}
module.exports = { getDpNumber, toHex, swapKeyValue, chainData }
