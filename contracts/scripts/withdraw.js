module.exports = async function(callback) {
    try {
        const Crowdsale = artifacts.require("Crowdsale");
        const crowdsale = await Crowdsale.deployed();
        crowdsale.withdraw().then((result) => { console.log(result); });
        callback();
    }
    catch(e) {
        callback(e);
    }
}
