module.exports = function(callback) {
    try {
        let etherPrice = parseInt(process.argv[4]);
        if (!process.argv[4] || isNaN(process.argv[4]) || !etherPrice)
            throw 'Bad or missing argument';
        const Crowdsale = artifacts.require("Crowdsale");
        const crowdsale = Crowdsale.at('0xaf9e40360c6e52f0736e30942e2258ce2b0b9d3f');
        crowdsale.updateEtherPrice(etherPrice).then((result) => { console.log(result); });
        callback();
    }
    catch(e) {
        callback(e);
    }
}



