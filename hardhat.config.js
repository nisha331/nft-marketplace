require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
const fs = require('fs');
// const infuraId = fs.readFileSync(".infuraid").toString().trim() || "";

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337
    },
    sepolia : {
      url: "https://eth-sepolia.g.alchemy.com/v2/aoDHulQ6KFBBWU8hGAG0zJeGMARPFK5N",
      accounts: [ "bbbef83ec1cbbfce2f4d8542bcfec9237a11983331a63535adeca6c4e205e5bd","14bb5f420bf3de5f7e8a908eec38960b7e78029c5e1dc6b0f4a2b147904170b0"]
    }
  },
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
};