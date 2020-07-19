const Migrations = artifacts.require('./Migrations.sol');
const Ed25519 = artifacts.require('./Ed25519.sol');
const FactomBridge = artifacts.require('./FactomBridge.sol');
const web3 = require('web3');
module.exports = async function (deployer) {
    await deployer.deploy(Migrations);
    await deployer.deploy(Ed25519);
    await deployer.deploy(FactomBridge, (await Ed25519.deployed()).address,
        web3.utils.toBN(1e18), web3.utils.toBN(10), web3.utils.toBN(20));
};