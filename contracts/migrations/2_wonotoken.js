var WonoToken = artifacts.require("./WonoToken.sol");

module.exports = function(deployer, network, accounts) {
    deployer
    .deploy(WonoToken)
    .then(() => {
        console.log(`\x1b[36;1m${WonoToken.address}\x1b[0m`);
    })
    .catch((e) => {
        console.error(`\x1b[31;1m${e}\x1b[0m`);
    });
};
