var BonusMeter = artifacts.require("./BonusMeter.sol");
var Crowdsale = artifacts.require("./Crowdsale.sol");

module.exports = function(deployer, network, accounts) {
    Crowdsale.deployed()
    .then((c) => {
        console.log(`Crowdsale at ${c.address}`);
        return deployer.deploy(BonusMeter, c.address);
    })
    .then(() => {
        console.log(`\x1b[36;1m${BonusMeter.address}\x1b[0m`);
    })
    .catch((e) => {
        console.error(`\x1b[31;1m${e}\x1b[0m`);
    });
};

