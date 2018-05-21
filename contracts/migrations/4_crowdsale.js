const Crowdsale = artifacts.require("./Crowdsale.sol");
const Token = artifacts.require("./WonoToken.sol");
const Whitelist = artifacts.require("./Whitelist.sol");

module.exports = async (deployer) => {
    const creator = web3.eth.accounts[0];

    const token = await Token.deployed();
    const whitelist = await Whitelist.deployed();
    
    await deployer.deploy(Crowdsale, whitelist.address, token.address, creator);
    const crowdsale = await Crowdsale.deployed();
}
