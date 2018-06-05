module.exports = async function(callback) {
    try {
        const WonoToken = artifacts.require("WonoToken");
        const wonotoken = await WonoToken.deployed();
        wonotoken.release().then((result) => { console.log(result); });
        callback();
    }
    catch(e) {
        callback(e);
    }
}



