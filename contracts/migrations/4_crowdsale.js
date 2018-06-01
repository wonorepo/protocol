const Whitelist = artifacts.require("./Whitelist.sol");
const WonoToken = artifacts.require("./WonoToken.sol");
const Crowdsale = artifacts.require("./Crowdsale.sol");

module.exports = function(deployer) {
    let wonotoken;
    WonoToken.deployed().then(function(addr) { wonotoken = addr; });
    let whitelist;
    Whitelist.deployed().then(function(addr) { whitelist = addr; });
    deployer.deploy(Crowdsale, wonotoken, whitelist, web3.eth.accounts[0]);
};
