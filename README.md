# rainbowProxy
# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
yarn hardhat accounts
yarn hardhat compile
yarn hardhat clean
yarn hardhat test
yarn hardhat node
yarn scripts/sample-script.js
yarn hardhat help
```
### 工程项目介绍
    本工程主要内容包含为各个交易所代理合约部分(例如：uniswap、sushiswap、mdex、pancake ...)等 swap, 其中主要的处理逻辑是与各个 swap 交互(添加流动性、移除流动性、价格计算、币-币交换、抵押lpToken挖矿)。

### 测试框架
    hardhat