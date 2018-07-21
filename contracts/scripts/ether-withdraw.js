module.exports = async function(callback) {
    try {
        let purpose;
        if (!isNaN(parseInt(process.argv[4], 10)))
            purpose = parseInt(process.argv[4], 10);
        else
            throw 'Bad or missing argument';
        let amount;
        if (!isNaN(parseFloat(process.argv[5], 10)))
            amount = parseFloat(process.argv[5], 10)
        else
            throw 'Bad or missing argument';

        const EtherDistributor = artifacts.require("EtherDistributor");
        const etherDistributor = await EtherDistributor.deployed();
        etherDistributor.withdraw(purpose, web3.toWei(amount)).then((result) => { console.log(result); });
        callback();
    }
    catch(e) {
        callback(e);
    }
}




