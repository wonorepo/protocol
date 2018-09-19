var Crowdsale = artifacts.require("./Crowdsale.sol");
var EtherDistributor = artifacts.require("./EtherDistributor.sol");

module.exports = function(deployer, network, accounts) {
    let crowdsale;
    Crowdsale.deployed()
    .then((c) => {
        crowdsale = c;
    })
    .then(() => {
        console.log(`\x1b[1mCrowdsale found at ${crowdsale.address}\x1b[0m`);
        return deployer.deploy(EtherDistributor, crowdsale.address);
    })
    .then(() => {
        console.log(`\x1b[33;1m${EtherDistributor.address}\x1b[0m`);
    })
    .catch((e) => {
        console.error(`\x1b[31;1m${e}\x1b[0m`);
    });
};
