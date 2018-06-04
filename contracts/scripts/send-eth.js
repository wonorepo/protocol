module.exports = async function(callback) {
    try {
        if (isNaN(parseFloat(process.argv[5], 10)))
            throw 'Bad or missing argument';
        let to;
        if (process.argv[4] != null && process.argv[4].match(/^0x[0-9A-Fa-f]{40}$/))
            to = process.argv[4];
        else if (!isNaN(parseInt(process.argv[4], 10)))
            to = web3.eth.accounts[parseInt(process.argv[4], 10)];
        else
            throw 'Bad or missing argument';
        let from = null;
        if (process.argv[6] != null && process.argv[6].match(/^0x[0-9A-Fa-f]{40}$/))
            from = process.argv[6];
        else if (!isNaN(parseInt(process.argv[6], 10)))
            from = web3.eth.accounts[parseInt(process.argv[6], 10)];
        else
            from = web3.eth.defaultAccount || web3.eth.accounts[0];
        const txProps = {
            nonce: web3.eth.getTransactionCount(from),
            from: from,
            to: to,
            gas: 5000000,
            value: web3.toWei(parseFloat(process.argv[5]))
        };
        const tx = await web3.eth.sendTransaction(txProps);
        console.log(web3.eth.getTransactionReceipt(tx));
        console.log(txProps);
        callback();
    }
    catch (e) {
        callback(e);
    }
}

