const { ethers, upgrades } = require("hardhat");
const fs = require('fs');

async function main() {
  /*
    const ThunderChatProfileContract = await ethers.getContractFactory("ThunderChatProfileContract");
    console.log("Deploying ThunderChatProfileContract...");
    const thunderChatProfileContract = await upgrades.deployProxy(ThunderChatProfileContract,  ["0x412F1D5417a8288F570b4d4d93ACdE38910A8ba0"], {initializer: 'constructor'});
    console.log("ThunderChatProfileContract deployed to:", thunderChatProfileContract.address);
    */

    const ThunderChatProfileContract = await ethers.getContractFactory("ThunderChatProfileContract");
    console.log("Deploying ThunderChatProfileContract V1...");
    const contract = await upgrades.deployProxy(ThunderChatProfileContract, [], {
        constructorArgs: ["0x412F1D5417a8288F570b4d4d93ACdE38910A8ba0"],
        initializer: "initialize",
    });
    await contract.deployed();
    console.log("ThunderChatProfileContract V1 deployed to:", contract.address);

    
    // ThunderChatProfileContract = await ethers.getContractFactory("ThunderChatProfileContract");
    // thunderChatProfileContract = await upgrades.deployProxy(ThunderChatProfileContract, [], {
    //   contructorArgs: ['0x412F1D5417a8288F570b4d4d93ACdE38910A8ba0'],
    //   initializer: "initialize"
    // });
    // await thunderChatProfileContract.deployed();
    // console.log("ThunderChatProfileContract deployed to:", thunderChatProfileContract.address);

    const deployData = {
      ThunderChatProfileContract: contract.address,
    };
    
    const jsonString = JSON.stringify(deployData, null, 2);
    
    
    fs.writeFileSync('deploy.json', jsonString);
    /*
    const ThunderChatProfileContract = await ethers.getContractFactory("ThunderChatProfileContract");
    console.log("Deploying ThunderChatProfileContract...");
    const thunderChatProfileContract = await upgrades.deployProxy(ThunderChatProfileContract, ['0x412F1D5417a8288F570b4d4d93ACdE38910A8ba0'], { initializer: 'initialize' });
    console.log("thunderChatProfileContract deployed to:", thunderChatProfileContract.address);
    */
  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });