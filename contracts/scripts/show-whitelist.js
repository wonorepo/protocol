module.exports = async function(callback) {
    try {
        const Whitelist = artifacts.require("Whitelist");
        const whitelist = await Whitelist.deployed();
        for (let i in web3.eth.accounts)
            whitelist.isApproved(web3.eth.accounts[i]).then((result) => {console.log(`(${i}) ${web3.eth.accounts[i]} ${result}`);});
        callback();
    }
    catch(e) {
        callback(e);
    }
}


