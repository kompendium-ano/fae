var MarksIco = artifacts.require("./WealthToken.sol");

module.exports = function(deployer, network, accounts) {
    if (network === "live") {
        // TODO
    } else {
        var newOwner = accounts[0];
        var newWallet = accounts[0];
        var nowInSeconds = Math.floor(Date.now() / 1000);
        deployer.deploy(WealthToken, newOwner, nowInSeconds, newWallet, 8000 * Math.pow(10, 18),
            8000 * Math.pow(10, 18), 120000 * Math.pow(10, 18));
    }
};