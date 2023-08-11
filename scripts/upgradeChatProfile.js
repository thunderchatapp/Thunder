const { ethers, upgrades } = require("hardhat");
const fs = require('fs');

async function main() {
    
    const PROXY = "0x9Be5D2292788850c24EE39dd2b533907F1E52f18";

    const ThunderChatProfileContract = await ethers.getContractFactory("ThunderChatProfileContract");
    
    console.log("Upgrading ThunderChatProfileContract V1...");
    
    const contract = await upgrades.upgradeProxy(PROXY, ThunderChatProfileContract, {
        constructorArgs: ["0x412F1D5417a8288F570b4d4d93ACdE38910A8ba0"]
    });
    
    

  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });