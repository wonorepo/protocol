module.exports = function(callback) {
    try {
        console.log('');
        web3.eth.getAccounts(
            function(err, accounts) {
                for (let i in accounts) {
                    console.log(`(${i}) ${accounts[i]} ${web3.fromWei(web3.eth.getBalance(accounts[i]))}`);
                }
            }
        );
        callback();
    }
    catch (e) {
        callback(e);
    }
}
