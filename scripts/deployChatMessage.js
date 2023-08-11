const { ethers, upgrades } = require("hardhat");
const fs = require('fs');

async function main() {


    // Deploy ThunderChatMessageContract
  const ThunderChatMessageContract = await ethers.getContractFactory("ThunderChatMessageContract");
  const thunderChatMessageContract = await upgrades.deployProxy(ThunderChatMessageContract, [], {
    constructorArgs: ["0x412F1D5417a8288F570b4d4d93ACdE38910A8ba0"],
    initializer: "initialize",
  });
  await thunderChatMessageContract.deployed();
  //console.log("ThunderChatMessageContract deployed to:", thunderChatMessageContract.address);

  // Set the profile contract address in ThunderChatMessageContract
  //await thunderChatMessageContract.setProfileContract('0x0d4013F76a2663341B7cBdDf18CC43134C16A05b');
  //console.log("Profile contract address set in ThunderChatMessageContract.");
}
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });