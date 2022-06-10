import { HardhatUserConfig } from 'hardhat/types';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';
import "hardhat-abi-exporter";
import "hardhat-contract-sizer";
import "@nomiclabs/hardhat-truffle5";
import "@nomiclabs/hardhat-web3";
import { node_url} from './utils/network';

const accounts = {
  mnemonic: process.env.MNEMONIC || "test test test test test test test test test test test junk",
  // accountsBalance: "990000000000000000000",
}
const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: '0.8.0',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
    ]
  },
  namedAccounts: {
    deployer: 0,
    dev: 1,
  },
  paths: {
    sources: 'contracts',
  },
  networks: {
    rinkeby: {
      url: node_url('RINKEBY'),
      accounts,
      chainId: 4,
      live: true,
      saveDeployments: true,
      gas:'auto',
      gasPrice: 'auto',
      gasMultiplier: 1.5,
      timeout:120000
    },
    bsctest:{
      url: node_url('BSCTEST'),
      accounts,
      chainId: 97,
      live: true,
      saveDeployments: true,
      gas:'auto',
      gasPrice: 'auto',
      gasMultiplier: 1.5,
      timeout:120000
    },
    bsc:{
      url:node_url('BSC'),
      accounts,
      chainId:56,
      saveDeployments:true,
      gas:'auto',
      gasPrice:'auto',
      gasMultiplier:1.5,
      timeout:120000
    },
    heco:{
      url:node_url('HECO'),
      accounts,
      chainId:128,
      saveDeployments:true,
      gas:'auto',
      gasPrice:'auto',
      gasMultiplier:1.5,
      timeout:120000
    }
  },
  abiExporter: {
    path: "./data/abi",
    clear: false,
    flat: true,
    only: ['MdexHecoProxy', 'PancakeSwapProxy', 'SuShiSwapProxy','UniswapV3Proxy'],
    // except: []
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: false,
    disambiguatePaths: false,
  },
};
export default config;
