import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';

const { moduleExcute, readConfFile } = require("./tool");

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNamedAccounts, getChainId } = hre;
    const { deploy } = deployments;

    const { deployer, dev } = await getNamedAccounts();
    const chainId = await getChainId();
    const confFile = await readConfFile(chainId);
    const addressConf = JSON.parse(confFile);
    const args = [addressConf.administer];
    await moduleExcute(deploy, 'UniswapV3Proxy', chainId, deployer,"","uniswapV3Proxy");
};
export default func;
func.tags = ['UniswapV3'];

