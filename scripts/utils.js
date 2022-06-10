module.exports = {
  delay: (ms) => new Promise((r) => setTimeout(r, ms)),
  getNetworkName: (networkId) => {
    switch (networkId) {
      case 1:
        return "mainnet"
      case 3:
        return "ropsten"
      case 4:
        return "rinkeby"
      case 42:
        return "kovan"
      case 128:
        return "heco"
      case 56:
        return "bsc"
      case 97:
        return "bsctest"
    }

    return "development"
  },
}
