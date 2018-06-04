module.exports = function(callback) {
    try {
        for (let i in web3.eth.accounts) {
            console.log(`(${i}) ${web3.eth.accounts[i]} ${web3.fromWei(web3.eth.getBalance(web3.eth.accounts[i]))}`);
        }
        callback();
    }
    catch (e) {
        callback(e);
    }
}
