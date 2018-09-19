module.exports = async function(callback) {
    try {
        let startTimestamp = parseInt(process.argv[4]);
        if (!process.argv[4] || isNaN(process.argv[4]) || !startTimestamp)
            throw 'Bad or missing argument 1';
        let endTimestamp = parseInt(process.argv[5]);
        if (!process.argv[5] || isNaN(process.argv[5]) || !endTimestamp)
            throw 'Bad or missing argument 2';
        const Crowdsale = artifacts.require("Crowdsale");
        const crowdsale = await Crowdsale.deployed();
        crowdsale.start(startTimestamp, endTimestamp).then((result) => { console.log(result); });
        callback();
    }
    catch(e) {
        callback(e);
    }
}



