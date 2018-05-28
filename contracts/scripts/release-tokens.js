module.exports = function(callback) {
    try {
        const Crowdsale = artifacts.require("Crowdsale");
        const crowdsale = Crowdsale.at('0xaf9e40360c6e52f0736e30942e2258ce2b0b9d3f');
        crowdsale.releaseTokens().then((result) => { console.log(result); });
        callback();
    }
    catch(e) {
        callback(e);
    }
}



