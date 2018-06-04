module.exports = async function(callback) {
    try {
        if (isNaN(parseFloat(process.argv[5], 10)))
            throw 'Bad or missing argument';
        let address;
        if (process.argv[4] != null && process.argv[4].match(/^0x[0-9A-Fa-f]{40}$/))
            address = process.argv[4];
        else if (!isNaN(parseInt(process.argv[4], 10)))
            address = web3.eth.accounts[parseInt(process.argv[4], 10)];
        else
            throw 'Bad or missing argument';
        const WonoToken = artifacts.require("WonoToken");
        const token = await WonoToken.deployed();
        token.transfer(address, web3.toWei(parseFloat(process.argv[5], 10))).then((result) => {console.log(result);});
        callback();
    }
    catch(e) {
        callback(e);
    }
}
