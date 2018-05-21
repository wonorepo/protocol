const Token = artifacts.require("./WonoToken.sol");

module.exports = async (deployer) => {
    const creator = web3.eth.accounts[0];

    await deployer.deploy(Token);
    const token = await Token.deployed();
}
