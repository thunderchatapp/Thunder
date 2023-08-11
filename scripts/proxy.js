const hre = require("hardhat");

async function main() {
  // Compile the contract
  await hre.run("compile");


  // const ThunderChatProfileContract = await hre.ethers.getContractFactory("ThunderChatProfileContract");
  // const thunderChatProfileContract = await ThunderChatProfileContract.deploy('0xAd77B6fB6B1245df29Ee6833f635439561f84c48');
  // await thunderChatProfileContract.deployed();
  // console.log("ThunderChatProfileContract deployed to:", thunderChatProfileContract.address);



  // Deploy the ThunderChatProfileContract using Hardhat's upgrades.deployProxy function
  const AdminRoleRegistry = await ethers.getContractFactory("ThunderChatProfileContract");
  const adminRoleRegistry = await upgrades.deployProxy(AdminRoleRegistry, ['forwarder: 0x412F1D5417a8288F570b4d4d93ACdE38910A8ba0','0xFCf9B122C8e2182F621887fA2B568fB7811D8956']);

  await adminRoleRegistry.deployed();
  console.log("ThunderChatProfileContract deployed to:", adminRoleRegistry.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
