var Crowdsale = artifacts.require("./Crowdsale.sol");
var TokenDistributor = artifacts.require("./TokenDistributor.sol");

module.exports = function(deployer, network, accounts) {
    let crowdsale;
    Crowdsale.deployed()
    .then((c) => {
        crowdsale = c;
    })
    .then(() => {
        console.log(`\x1b[1mCrowdsale found at ${crowdsale.address}\x1b[0m`);
        return deployer.deploy(TokenDistributor, crowdsale.address);
    })
    .then(() => {
        console.log(`\x1b[34;1m${TokenDistributor.address}\x1b[0m`);
    })
    .catch((e) => {
        console.error(`\x1b[31;1m${e}\x1b[0m`);
    });
};
