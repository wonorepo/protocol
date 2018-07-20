module.exports = async function(callback) {
    try {
        let purpose;
        if (!isNaN(parseInt(process.argv[4], 10)))
            purpose = parseInt(process.argv[4], 10);
        else
            throw 'Bad or missing argument';
        const TokenDistributor = artifacts.require("TokenDistributor");
        const tokenDistributor = await TokenDistributor.deployed();
        tokenDistributor.getTokensAvailable(purpose).then((result) => { console.log(web3.fromWei(result).toString()); });
        callback();
    }
    catch(e) {
        callback(e);
    }
}




