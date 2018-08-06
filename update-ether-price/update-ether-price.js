module.exports = async function(callback) {
    try {
        let etherPrice = parseFloat(process.argv[6]);
        if (!etherPrice)
            throw 'Bad or missing argument';
        const Crowdsale = artifacts.require("Crowdsale");
        const crowdsale = await Crowdsale.deployed();
        console.log("Setting Ethereum price to \x1b[1m" + etherPrice + "\x1b[0m");
        crowdsale.updateEtherPrice(web3.toWei(etherPrice)).then((result) => { console.log(result); });
        callback();
    }
    catch(e) {
        callback(e);
    }
}



