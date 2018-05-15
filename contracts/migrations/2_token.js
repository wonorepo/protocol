const Token = artifacts.require("../contracts/WonoToken.sol");

module.exports = async (deployer) => {
    const creator = web3.eth.accounts[0];

    await deployer.deploy(Token);
    const token = await Token.deployed();
    await token.allocate(creator, web3.toWei(47500000, 'ether'));
}
