module.exports = {
  networks: {
    main: {
      host: 'localhost',
      port: 8540,
      network_id: 1
    },
    development: {
      host: 'localhost',
      port: 8545,
      network_id: '*',
      gas: 5000000
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 10
    }
  }
}
