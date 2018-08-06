module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 8545,
      network_id: 513,
      gas: 5000000,
      gasPrice: 2000000000,
      from: '0x58bb9e15db607bcf3d1a9a78a5a71cb45adf18d5'
    },
    testnet: {
      host: 'localhost',
      port: 8545,
      network_id: 8617,
      gas: 80000000,
      gasPrice: 2000000000,
      from: '0xeD120005a06B5b8fb003BAb27B7a7f18f090caFe'
    },
    kovan: {
      host: 'localhost',
      port: 8545,
      network_id: 42,
      gas: 4700000,
      gasPrice: 2000000000,
      from: '0xeD120005a06B5b8fb003BAb27B7a7f18f090caFe'
    }	    
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
}
