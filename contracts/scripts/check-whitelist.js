module.exports = function(callback) {
    try {
        const Whitelist = artifacts.require("Whitelist");
        const whitelist = Whitelist.at('0x0759939533e1f59e16c1fe7a2e736f0a3cf570b8');
        for (let i in web3.eth.accounts)
            whitelist.isApproved(web3.eth.accounts[i]).then((result) => {console.log(`(${i}) ${web3.eth.accounts[i]} ${result}`);});
        callback();
    }
    catch(e) {
        callback(e);
    }
}


