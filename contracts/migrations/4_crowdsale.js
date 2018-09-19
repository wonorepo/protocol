var Whitelist = artifacts.require("./Whitelist.sol");
var WonoToken = artifacts.require("./WonoToken.sol");
var Crowdsale = artifacts.require("./Crowdsale.sol");

module.exports = function(deployer, network, accounts) {
    let whitelist;
    let wonotoken;
    Whitelist.deployed()
    .then((c) => {
        whitelist = c;
    })
    .then(() => {
        return WonoToken.deployed();
    })
    .then((c) => {
        wonotoken = c;
    })
    .then(() => {
        console.log(`\x1b[1mWonoToken found at ${wonotoken.address}\x1b[0m`);
        console.log(`\x1b[1mWhitelist found at ${whitelist.address}\x1b[0m`);
        return deployer.deploy(Crowdsale, wonotoken.address, whitelist.address)
    })
    .then(() => {
        console.log(`\x1b[35;1m${Crowdsale.address}\x1b[0m`);
    })
    .catch((e) => {
        console.error(`\x1b[31;1m${e}\x1b[0m`);
    });
};
