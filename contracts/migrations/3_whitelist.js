const Whitelist = artifacts.require("./Whitelist.sol");

module.exports = async (deployer) => {
    const creator = web3.eth.accounts[0];

    await deployer.deploy(Whitelist);
    const token = await Whitelist.deployed();
}
