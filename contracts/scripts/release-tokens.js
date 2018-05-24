module.exports = function(callback) {
    try {
        const WonoToken = artifacts.require("WonoToken");
        const token = WonoToken.at('0x7a4471267b797428a6a51cc73fbc9397710f4572');
        token.release().then((result) => { console.log(result); });
        callback();
    }
    catch(e) {
        callback(e);
    }
}



