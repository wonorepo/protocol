module.exports = function(callback) {
    try {
        const tx = web3.eth.sendTransaction({
            nonce: web3.eth.getTransactionCount(web3.eth.accounts[0]),
            gasPrice: web3.toHex(web3.toWei('4', 'gwei')),
            gasLimit: 40000,
            from: web3.eth.accounts[0],
            to: web3.eth.accounts[1],
            value: web3.toWei(10)
        })
        console.log(web3.eth.getTransactionReceipt(tx));
        callback();
    }
    catch (e) {
        callback(e);
    }
}

