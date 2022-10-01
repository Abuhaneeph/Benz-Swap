require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();
require("@nomicfoundation/hardhat-chai-matchers");


const ALCHEMY_KEY=process.env.ALCHEMY_KEY;
const GOERLI_PRIVATE_KEY=process.env.GOERLI_KEY;


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  //defaultNetwork: "",
  networks: {
    hardhat: {
      chainId: 31337,
    },
    goerli: {
      chainId: 5,
      url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_KEY}`,
      accounts: [GOERLI_PRIVATE_KEY]
    }
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 40000
  }
}