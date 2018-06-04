module.exports = async function(callback) {
    try {
        let etherPrice = parseInt(process.argv[4]);
        if (!process.argv[4] || isNaN(process.argv[4]) || !etherPrice)
            throw 'Bad or missing argument';
        const Crowdsale = artifacts.require("Crowdsale");
        const crowdsale = await Crowdsale.deployed();
        crowdsale.updateEtherPrice(etherPrice).then((result) => { console.log(result); });
        callback();
    }
    catch(e) {
        callback(e);
    }
}



