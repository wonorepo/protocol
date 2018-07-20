module.exports = async function(callback) {
    try {
        const TokenDistributor = artifacts.require("TokenDistributor");
        const tokenDistributor = await TokenDistributor.deployed();
        tokenDistributor.distribute().then((result) => { console.log(result); });
        callback();
    }
    catch(e) {
        callback(e);
    }
}




