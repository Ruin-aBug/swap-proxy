const argv = require("yargs")
  // .demandOption(
  //   ["network"],
  //   "Please provide [network] argument to work with this tool",
  // )
  .option("network", {
    alias: "net",
    default: "mainnet",
  })
  .option("configure", {
    alias: "conf",
    default: "./scripts/initData.json",
  })
  .usage("Usage: initData [options]")
  .help("h")
  .alias("h", "help")
  .option("version", {
    alias: "v",
    describe: "version 0.0.1",
  })
  .epilog("copyright 2021 rainbow fundation").argv
const FileSystem = require("fs")
const { start } = require("repl")
async function readFile(fileName) {
  return new Promise(async (resolve, reject) => {
    try {
      FileSystem.readFile(fileName, "utf-8", (err, data) => {
        if (err) {
          reject(err)
        } else {
          resolve(data)
        }
      })
    } catch (e) {
      reject(e)
    }
  })
}

async function writeFile(fileName, content) {
  return new Promise(async (resolve, reject) => {
    try {
      FileSystem.writeFile(
        fileName,
        content,
        { encoding: "utf8", flag: "w+" },
        (err) => {
          if (err) {
            reject(err)
          } else {
            resolve(null)
          }
        },
      )
    } catch (e) {
      reject(e)
    }
  })
}

const chainData = {
  mainnet: 1,
  heco: 128,
  bsc: 56,
  rinkeby: 4,
  bsctest: 97,
}

class BaseModule {
  constructor() {
    this.config = {
      dataFile: argv.configure,
    }
    this.chainName = argv.network.toLowerCase()
    this.chainId = chainData[this.chainName]
  }

  async start() {
    await this.run()
  }

  async run() {
    console.log("this is BaseModule run Function")
  }

  async getJsonContent(fileName) {
    let fileData = await readFile(fileName)
    if (fileData) {
      return JSON.parse(fileData)
    }
    return undefined
  }

  async initialize() {
    try {
      if (!chainData[this.chainName]) {
        console.log("network id ，不支持的链")
        return false
      }

      this.config.initData = await this.getJsonContent(this.config.dataFile)
      console.log(this.config.initData)
    } catch (e) {
      console.log(e)
      return false
    }
    return true
  }
}

module.exports = { BaseModule, readFile, writeFile, chainData }
