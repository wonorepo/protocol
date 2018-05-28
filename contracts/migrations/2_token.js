const WonoToken = artifacts.require("./WonoToken.sol");

module.exports = function(deployer) {
    deployer.deploy(WonoToken);
}
