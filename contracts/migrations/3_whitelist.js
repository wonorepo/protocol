var Whitelist = artifacts.require("./Whitelist.sol");

module.exports = function(deployer, network, accounts) {
    deployer
    .deploy(Whitelist)
    .then(() => {
        console.log(`\x1b[32;1m${Whitelist.address}\x1b[0m`);
    })
    .catch((e) => {
        console.error(`\x1b[31;1m${e}\x1b[0m`);
    });
};
