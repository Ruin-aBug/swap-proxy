import { ethers, deployments, getNamedAccounts } from "hardhat"

async function main() {
  const { deploy } = deployments

  const { deployer } = await getNamedAccounts()

  const TestRainbow = deploy("TestRainbow", {
    from: deployer,
    args: [deployer],
    log: true,
  })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
