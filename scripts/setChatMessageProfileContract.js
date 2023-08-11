const { ethers } = require("hardhat");

async function main() {
    // Replace with the actual deployed contract address
    const thunderChatMessageContractAddress = "0xbd9daec380F5f698918D288bcbF4EBE29ACBBfc1"; // The address of your deployed contract

    // Connect to the deployed contract
    const ThunderChatMessageContract = await ethers.getContractFactory("ThunderChatMessageContract");
    const thunderChatMessageContract = await ThunderChatMessageContract.attach(thunderChatMessageContractAddress);

    // Call the setProfileContract function
    const profileContractAddress = "0x0d4013F76a2663341B7cBdDf18CC43134C16A05b"; // The address of the profile contract you want to set
    const tx = await thunderChatMessageContract.setProfileContract(profileContractAddress);

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
