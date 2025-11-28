const { ethers } = require("hardhat");

async function main() {
  const ChainArtMarket = await ethers.getContractFactory("ChainArtMarket");
  const chainArtMarket = await ChainArtMarket.deploy();

  await chainArtMarket.deployed();

  console.log("ChainArtMarket contract deployed to:", chainArtMarket.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
