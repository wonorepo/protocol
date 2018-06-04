module.exports = async function(callback) {
    try {
        const WonoToken = artifacts.require("WonoToken");
        const token = await WonoToken.deployed();
        const Crowdsale = artifacts.require("Crowdsale");
        const crowdsale = await Crowdsale.deployed();
        token.transferOwnership(crowdsale.address).then((result) => {console.log(result);});
        callback();
    }
    catch(e) {
        callback(e);
    }
}
