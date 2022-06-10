const fs = require("fs");
async function readConfFile(chainId: Number) {
    return new Promise<string>(async (resolve, reject) => {
        try {
            const network = getNetWorkName(chainId);
            const fileName = `conf/address-${network}.json`;
            console.log(fileName);
            fs.readFile(fileName, "utf-8", (err: string, data: string) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(data);
                }
            })
        } catch (e) {
            reject(e);
        }
    })
}

async function moduleExcute(deploy: any, contract: string, chainId: Number, deployer: string, args: string[], proxyName:String) {
        const network = getNetWorkName(chainId);
        console.log("当前部署网络：", network);
        try {
            const confFileName = `conf/address-${network}.json`;
            const fileName = await readConfFile(chainId);
            
            let proxy;
            if (args) {
                proxy = await deploy(contract, {
                    from: deployer,
                    args: args,
                    log: true
                });
            }else{
                proxy = await deploy(contract, {
                    from: deployer,
                    log: true
                });
            }
            const addressConfJson = JSON.parse(fileName);
            addressConfJson[`${proxyName}`] = proxy.address;
            fs.writeFileSync(confFileName, JSON.stringify(addressConfJson), "utf8");
        } catch (e) {
            console.log(e);
        }
}

async function moduleRun(network: Number, run: any) {
    try {
        const confFileName = `conf/address-${network}.json`;
        const fileName = await readConfFile(network);
        const addressConf = JSON.parse(fileName);

        await run(addressConf, confFileName, network);

        fs.writeFileSync(confFileName, JSON.stringify(addressConf), "utf8");
    } catch (e) {
        console.log(e);
    }
}

function upStrFirstChar(str: string) {
    return str[0].toUpperCase() + str.substr(1);
}

function getUseNetworkName(str: string) {
    if (str == "Rinkeby") {
        return "Mainnet";
    }
    return str;
}

function getNetWorkName(chainId: Number) {
    switch (Number(chainId)) {
        case 1:
            return "mainnet";
        case 3:
            return "ropsten";
        case 4:
            return "rinkeby";
        case 42:
            return "kovan";
        case 128:
            return "heco";
        case 56:
            return "bsc";
        case 97:
            return "bsctest";
        default:
            return "development";
    }
}


module.exports = {
    upStrFirstChar,
    moduleExcute,
    readConfFile,
    getUseNetworkName,
    getNetWorkName,
    moduleRun,
};
