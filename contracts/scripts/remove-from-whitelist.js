module.exports = async function(callback) {
    try {
        let address;
        if (process.argv[4] != null && process.argv[4].match(/^0x[0-9A-Fa-f]{40}$/))
            address = process.argv[4];
        else if (!isNaN(parseInt(process.argv[4], 10)))
            address = web3.eth.accounts[parseInt(process.argv[4], 10)];
        else
            throw 'Bad or missing argument';
        const Whitelist = artifacts.require("Whitelist");
        const whitelist = await Whitelist.deployed();
        whitelist.declineAddress(address).then((result) => {console.log(result);});
        callback();
    }
    catch(e) {
        callback(e);
    }
}

