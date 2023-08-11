/** @type import('hardhat/config').HardhatUserConfig */

require("@nomiclabs/hardhat-ethers");
require('@openzeppelin/hardhat-upgrades');


const {config} = require("dotenv");
const {resolve} = require("path");

config({ path: resolve(__dirname, "./.env")});

module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      evmVersion: 'paris'
    },
    settings: {
      optimizer: {
        runs: 200,
        enabled: true
      }
    },
  },
  networks: {
    AB: {
        url: `https://arb-goerli.g.alchemy.com/v2/${process.env.alchemyApiKey}`,
        chainId: 421613,
        accounts: [`0x${process.env.TESTNET_PRIVATE_KEY}`]
    },
    ABNova: {
      url: `https://arb-goerli.g.alchemy.com/v2/${process.env.alchemyApiKey}`,
      chainId: 421613,
      accounts: [`0x${process.env.TESTNET_PRIVATE_KEY}`]
    }
  }

  
};

