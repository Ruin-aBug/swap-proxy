const { swapKeyValue } = require("./utils")

var addressInfo = {}
var nameInfo = {}

function initChainTokens(tokens, chainId) {
  for (let name in tokens) {
    try {
      if (tokens[name].address[chainId]) {
        nameInfo[tokens[name].symbol] = tokens[name].address[chainId]
      }
    } catch (e) {
      console.log(e.message)
    }
  }
  addressInfo = swapKeyValue(nameInfo)
}

function getTokenSymbol(tokenAddress, chainId) {
  if (!addressInfo || Object.keys(addressInfo).length == 0) {
    initChainTokens(chainId)
  }
  const symbol = addressInfo[tokenAddress]
  if (symbol == undefined) {
    return "暂无此币种1"
  }
  return symbol
}

function getTokenName(address, chainId) {
  return getTokenSymbol(address, chainId)
}

function getTokenAddress(symbol, chainId) {
  if (!nameInfo || Object.keys(nameInfo).length == 0) {
    initChainTokens(chainId)
  }
  const address = nameInfo[symbol]
  if (address == undefined) {
    return "暂无此币种2"
  }
  return address
}

function getTokenDecimal(tokens, symbol, chainId) {
  let tokenItem = tokens[symbol.toLowerCase()]
  if (!tokenItem) {
    // 这种情况这里可能是地址
    const symbolName = getTokenName(symbol)
    if (symbolName) {
      tokenItem = tokens[symbolName.toLowerCase()]
    }
  }
  if (tokenItem) {
    if (tokenItem.dec && tokenItem.dec[chainId]) {
      return tokenItem.dec[chainId]
    }
    return tokenItem.decimals
  }
  console.log(symbol, "暂无此币种3")
  return "暂无此币种3"
}

module.exports = {
  getTokenDecimal,
  getTokenAddress,
  getTokenName,
  getTokenSymbol,
  initChainTokens,
}
