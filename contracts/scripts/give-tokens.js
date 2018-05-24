module.exports = function(callback) {
    try {
        if (!process.argv[5] || isNaN(process.argv[5]) || !parseFloat(process.argv[5]))
            throw 'Bad or missing argument';
        let address;
        if (process.argv[4].match(/^0x[0-9A-Fa-f]{40}$/))
            address = process.argv[4];
        else if (parseInt(process.argv[4], 10))
            address = web3.eth.accounts[parseInt(process.argv[4], 10)];
        else
            throw 'Bad or missing argument';
        const WonoToken = artifacts.require("WonoToken");
        const token = WonoToken.at('0x7a4471267b797428a6a51cc73fbc9397710f4572');
        token.give(address, web3.toWei(parseFloat(process.argv[5]))).then((result) => {console.log(result);});
        callback();
    }
    catch(e) {
        callback(e);
    }
}



