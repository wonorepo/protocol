const Crowdsale = artifacts.require("./Crowdsale.sol");
const Whitelist = artifacts.require("./Whitelist.sol");
const WonoToken = artifacts.require("./WonoToken.sol");

module.exports = function(deployer) {
    WonoToken.deployed()
    .then(function(wonotoken) {
        Whitelist.deployed()
        .then(function(whitelist) {
            let result = deployer.deploy(Crowdsale, whitelist.address, wonotoken.address, web3.eth.accounts[0]);
            result.then(function(result) {
                Crowdsale.deployed()
                .then(function(crowdsale) {
                    console.log(`\x1b[35;1m${crowdsale.address}\x1b[0m`);
                });
            });
            return result;
        });
    });
};
