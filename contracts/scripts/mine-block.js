module.exports = async function(callback) {
    try {
        web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0});
        callback();
    }
    catch(e) {
        callback(e);
    }
}
