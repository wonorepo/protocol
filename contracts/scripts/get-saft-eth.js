module.exports = async function(callback) {
    try {
        const Crowdsale = artifacts.require("Crowdsale");
        const crowdsale = await Crowdsale.deployed();
        crowdsale.getSAFTEth.call().then((result) => {console.log(web3.fromWei(result).toString());});
        callback();
    }
    catch(e) {
        callback(e);
    }
}




