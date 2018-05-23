module.exports = function(callback) {
    try {
        const Whitelist = artifacts.require("Whitelist");
        const whitelist = Whitelist.at('0x0759939533e1f59e16c1fe7a2e736f0a3cf570b8');
        whitelist.addAddress(web3.eth.accounts[1]).then((receipt) => {console.log(receipt);});
        whitelist.addAddress(web3.eth.accounts[2]).then((receipt) => {console.log(receipt);});
        whitelist.addAddress(web3.eth.accounts[3]).then((receipt) => {console.log(receipt);});
        whitelist.addAddress(web3.eth.accounts[4]).then((receipt) => {console.log(receipt);});
        whitelist.addAddress(web3.eth.accounts[5]).then((receipt) => {console.log(receipt);});
        callback();
    }
    catch(e) {
        callback(e);
    }
}
