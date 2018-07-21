module.exports = async function(callback) {
    try {
        const EtherDistributor = artifacts.require("EtherDistributor");
        const etherDistributor = await EtherDistributor.deployed();
        etherDistributor.distribute().then((result) => { console.log(result); });
        callback();
    }
    catch(e) {
        callback(e);
    }
}




