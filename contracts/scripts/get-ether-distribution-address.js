module.exports = async function(callback) {
    try {
        const EtherDistributor = artifacts.require("EtherDistributor");
        const etherDistributor = await EtherDistributor.deployed();
        console.log(etherDistributor.address);
        callback();
    }
    catch(e) {
        callback(e);
    }
}




