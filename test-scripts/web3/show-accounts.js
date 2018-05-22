web3.eth.getAccounts(function(err, accounts) { console.log(''); for (let i in accounts) { console.log(`(${i}) ${accounts[i]} ${web3.fromWei(web3.eth.getBalance(accounts[i]))}`); } } );
