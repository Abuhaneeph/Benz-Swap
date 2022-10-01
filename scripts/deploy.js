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


 const entranceFee=10000000000000000;
 const subscriptionId=288
 const RaffleFactory= await ethers.getContractFactory("Raffle");
 const Raffle= await RaffleFactory.deploy(entranceFee,subscriptionId);

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
