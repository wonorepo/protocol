module.exports = function(callback) {
    try {
        const WonoToken = artifacts.require("WonoToken");
        const token = WonoToken.at('0x7a4471267b797428a6a51cc73fbc9397710f4572');
        token.transferOwnership('0xaf9e40360c6e52f0736e30942e2258ce2b0b9d3f').then((result) => {console.log(result);});
        callback();
    }
    catch(e) {
        callback(e);
    }
}
