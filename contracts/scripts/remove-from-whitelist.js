module.exports = function(callback) {
    try {
        let address;
        if (!process.argv[4])
            throw 'Bad or missing argument';
        if (process.argv[4].match(/^0x[0-9A-Fa-f]{40}$/))
            address = process.argv[4];
        else if (parseInt(process.argv[4], 10))
            address = web3.eth.accounts[parseInt(process.argv[4], 10)];
        else
            throw 'Bad or missing argument';
        const Whitelist = artifacts.require("Whitelist");
        const whitelist = Whitelist.at('0x0759939533e1f59e16c1fe7a2e736f0a3cf570b8');
        whitelist.declineAddress(address).then((result) => {console.log(result);});
        callback();
    }
    catch(e) {
        callback(e);
    }
}

