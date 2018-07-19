module.exports = async function(callback) {
    try {
        let startTimestamp = parseInt(process.argv[4]);
        if (!process.argv[4] || isNaN(process.argv[4]) || !startTimestamp)
            throw 'Bad or missing argument 1';
        let endTimestamp = parseInt(process.argv[5]);
        if (!process.argv[5] || isNaN(process.argv[5]) || !endTimestamp)
            throw 'Bad or missing argument 2';
        let fundingAddress;
        if (process.argv[6] != null && process.argv[6].match(/^0x[0-9A-Fa-f]{40}$/))
            fundingAddress = process.argv[6];
        else if (!isNaN(parseInt(process.argv[6], 10)))
            fundingAddress = web3.eth.accounts[parseInt(process.argv[6], 10)];
        else
            throw 'Bad or missing argument 3    ';
        const Crowdsale = artifacts.require("Crowdsale");
        const crowdsale = await Crowdsale.deployed();
        crowdsale.start(startTimestamp, endTimestamp, fundingAddress).then((result) => { console.log(result); });
        callback();
    }
    catch(e) {
        callback(e);
    }
}



