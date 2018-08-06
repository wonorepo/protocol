var Whitelist = artifacts.require("./Whitelist.sol");
var WonoToken = artifacts.require("./WonoToken.sol");
var Crowdsale = artifacts.require("./Crowdsale.sol");
var TokenDistributor = artifacts.require("./TokenDistributor.sol");
var EtherDistributor = artifacts.require("./EtherDistributor.sol");

module.exports = function(deployer, network, accounts) {
    deployer
    .deploy(WonoToken)
    .then(() => {
        return deployer.deploy(Whitelist)
    })
    .then(() => {
        return deployer.deploy(Crowdsale, WonoToken.address, Whitelist.address);
    })
    .then(() => {
        return deployer.deploy(EtherDistributor, Crowdsale.address);
    })
    .then(() => {
        return deployer.deploy(TokenDistributor, Crowdsale.address);
    })
    .then(() => {
        console.log(`\x1b[36;1m${WonoToken.address}\x1b[0m`);
        console.log(`\x1b[32;1m${Whitelist.address}\x1b[0m`);
        console.log(`\x1b[35;1m${Crowdsale.address}\x1b[0m`);
        console.log(`\x1b[33;1m${EtherDistributor.address}\x1b[0m`);
        console.log(`\x1b[34;1m${TokenDistributor.address}\x1b[0m`);
    })
    .catch((e) => {
        console.error(`\x1b[31;1m${e}\x1b[0m`);
    });
};
