module.exports = async function(callback) {
    try {
        let etherPrice = parseFloat(process.argv[4]);
        if (!process.argv[4] || isNaN(etherPrice) || !etherPrice)
            throw 'Bad or missing argument';
        const Crowdsale = artifacts.require("Crowdsale");
        const crowdsale = await Crowdsale.deployed();
        crowdsale.updateEtherPrice(web3.toWei(etherPrice)).then((result) => { console.log(result); });
        callback();
    }
    catch(e) {
        callback(e);
    }
}



