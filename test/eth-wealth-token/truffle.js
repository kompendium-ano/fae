module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    rinkeby: {
      host: "localhost",
      port: 8545,
      network_id: 4, //rinkeby test network
      gas: 4700000,
    },
    live: {
      host: "localhost", // use localhost to deploy contract
      port: 8545,
      network_id: 1, //mainnet network
      gas: 4700000,
      gasPrice: 12000000000,
    }
  },
}
