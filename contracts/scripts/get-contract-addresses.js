module.exports = async function(callback) {
    try {
        const WonoToken = artifacts.require('WonoToken');
        const Whitelist = artifacts.require('Whitelist');
        const Crowdsale = artifacts.require('Crowdsale');
        const addr = {
            wonotoken: await WonoToken.deployed().then((c) => {return c.address}),
            whitelist: await Whitelist.deployed().then((c) => {return c.address}),
            crowdsale: await Crowdsale.deployed().then((c) => {return c.address})
        };
        console.log(addr);
        callback();
    }
    catch(e) {
        callback(e);
    }
}

