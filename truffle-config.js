const fs = require('fs');
const HDWalletProvider = require('@truffle/hdwallet-provider');
// const infuraKey = "fj4jll3k.....";
const mnemonic = fs.readFileSync(".secret").toString().trim();
const apiKey = fs.readFileSync("bsc.key").toString().trim();

module.exports = {
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    bscscan: apiKey,
  },
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },
    bscTestnet: {
      provider: () => new HDWalletProvider(
        mnemonic,
        'https://data-seed-prebsc-1-s1.binance.org:8545'
      ),
      network_id: 97,
      skipDryRun: true,
      timeoutBlocks: 200,
      confirmations: 5,
      production: true    // Treats this network as if it was a public net. (default: false)
    },
    bscMainnet: {
      provider: () => new HDWalletProvider(
        mnemonic,
        'https://bsc-dataseed1.binance.org'
      ),
      network_id: 56,
      gas: 8500000,
      skipDryRun: true,
      networkCheckTimeout: 10000000,
      timeoutBlocks: 300,
      confirmations: 5,
      gasPrice: 20000000000,
      // websocket: true,
      production: true    // Treats this network as if it was a public net. (default: false)
    }
    // Another network with more advanced options...
    // advanced: {
    // port: 8777,             // Custom port
    // network_id: 1342,       // Custom network
    // gas: 8500000,           // Gas sent with each transaction (default: ~6700000)
    // gasPrice: 20000000000,  // 20 gwei (in wei) (default: 100 gwei)
    // from: <address>,        // Account to send txs from (default: accounts[0])
    // websocket: true        // Enable EventEmitter interface for web3 (default: false)
    // },
    // Useful for deploying to a public network.
    // NB: It's important to wrap the provider as a function.
    // ropsten: {
    // provider: () => new HDWalletProvider(mnemonic, `https://ropsten.infura.io/v3/YOUR-PROJECT-ID`),
    // network_id: 3,       // Ropsten's id
    // gas: 5500000,        // Ropsten has a lower block limit than mainnet
    // confirmations: 2,    // # of confs to wait between deployments. (default: 0)
    // timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
    // skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    // },
    // Useful for private networks
    // private: {
    // provider: () => new HDWalletProvider(mnemonic, `https://network.io`),
    // network_id: 2111,   // This network is yours, in the cloud.
    // production: true    // Treats this network as if it was a public net. (default: false)
    // }
  },
  mocha: {
    // timeout: 100000
  },
  compilers: {
    solc: {
      version: "0.8.6",
      docker: false,
      settings: {
        optimizer: {
          enabled: false,
          runs: 200
        },
        evmVersion: "berlin"
      }
    }
  },

  db: {
    enabled: false
  }
};
