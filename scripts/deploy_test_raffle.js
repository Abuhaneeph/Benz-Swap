// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers } = require("hardhat");


async function main() {
 const [deployer]= await ethers.getSigners();
 console.log("Deploying Contracts with accounts "+deployer.address)
 console.log("Account Balance "+ (await deployer.getBalance()).toString());

 
 const BASE_FEE = "250000000000000000" // 0.25 is this the premium in LINK?
 const GAS_PRICE_LINK = 1e9 // link per gas, is this the gas lane? // 0.000000001 LINK per gas 
 let vrfCoordinatorV2Address,subscriptionId
// if we are working on a testnet or a mainnet those addresses
// will exist otherwise .... they wont


 // make a fake chainlink VRF NODE
 const RaffleFactory= await ethers.getContractFactory("VRFCoordinatorV2Mock");
const Raffle= await RaffleFactory.deploy(BASE_FEE,GAS_PRICE_LINK)
     
     console.log("Raffle address "+Raffle.address)
 
    }
 
 

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
.then(()=>{
  process.exit(0);
})
.catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
