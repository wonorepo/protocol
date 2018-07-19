module.exports = async function(callback) {
    try {
        let seconds;
        if (!isNaN(parseInt(process.argv[4], 10)))
            seconds = parseInt(process.argv[4], 10);
        else
            throw 'Bad or missing argument';
        web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [seconds], id: 0});
        web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0});
        callback();
    }
    catch(e) {
        callback(e);
    }
}
