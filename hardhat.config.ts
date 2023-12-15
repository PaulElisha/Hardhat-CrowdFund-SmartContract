import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import "hardhat-deploy";
import "hardhat-deploy-ethers";
import "@typechain/hardhat";
import "typechain";
import * as dotenv from "dotenv";

dotenv.config();

const { SEPOLIA_RPC, PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;

const config: HardhatUserConfig = {
  solidity: {
    compilers: [{ version: "0.8.22" }],
  },
  defaultNetwork: "hardhat",
  networks: {
    sepolia: {
      url: SEPOLIA_RPC || "",
      accounts: [PRIVATE_KEY || ""],
      chainId: 11155111, // @ts-ignore
      blockConfirmations: 6,
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY || "",
  },
  sourcify: {
    enabled: true,
  },
  gasReporter: {
    enabled: true,
    outputFile: "gas-report.txt",
    noColors: true,
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
};

export default config;
