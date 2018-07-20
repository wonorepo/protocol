module.exports = async function(callback) {
    try {
        let purpose;
        if (!isNaN(parseInt(process.argv[4], 10)))
            purpose = parseInt(process.argv[4], 10);
        else
            throw 'Bad or missing argument';
        let address;
        if (process.argv[5] != null && process.argv[5].match(/^0x[0-9A-Fa-f]{40}$/))
            address = process.argv[5];
        else if (!isNaN(parseInt(process.argv[5], 10)))
            address = web3.eth.accounts[parseInt(process.argv[5], 10)];
        else
            throw 'Bad or missing argument';
        const TokenDistributor = artifacts.require("TokenDistributor");
        const tokenDistributor = await TokenDistributor.deployed();
        tokenDistributor.setDistributionAddress(purpose, address).then((result) => { console.log(result); });
        callback();
    }
    catch(e) {
        callback(e);
    }
}




