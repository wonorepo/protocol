module.exports = async function(callback) {
    try {
        const Crowdsale = artifacts.require("Crowdsale");
        const crowdsale = await Crowdsale.deployed();
	console.log(web3.fromWei(web3.eth.getBalance(crowdsale.address)).toString());
	crowdsale.getTotalCollectedEth().then((r) => { console.log(web3.fromWei(r).toString()) });
        callback();
    }
    catch(e) {
        callback(e);
    }
}

