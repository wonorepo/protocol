module.exports = async function(callback) {
    try {
        let startTimestamp = parseInt(process.argv[4]);
        const Crowdsale = artifacts.require("Crowdsale");
        const crowdsale = await Crowdsale.deployed();
        crowdsale.sterilize().then((result) => { console.log(result); });
        callback();
    }
    catch(e) {
        callback(e);
    }
}



