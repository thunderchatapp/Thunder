const { ethers, upgrades } = require("hardhat");
const fs = require('fs');

async function main() {
    
    const PROXY = "0xbd9daec380F5f698918D288bcbF4EBE29ACBBfc1";

    const ThunderChatMessageContract = await ethers.getContractFactory("ThunderChatMessageContract");
    
    console.log("Upgrading ThunderChatMessageContract...");
    
    const contract = await upgrades.upgradeProxy(PROXY, ThunderChatMessageContract, {
        constructorArgs: ["0x412F1D5417a8288F570b4d4d93ACdE38910A8ba0"]
    });

    // Call the setProfileContract function
    const profileContractAddress = "0x0d4013F76a2663341B7cBdDf18CC43134C16A05b"; // The address of the profile contract you want to set
    const tx = await contract.setProfileContract(profileContractAddress);

    // Wait for the transaction to be mined
    await tx.wait();
    console.log("Profile contract address set in ThunderChatMessageContract.");
    
  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });