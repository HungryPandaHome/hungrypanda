const HungryPanda = artifacts.require("HungryPanda");

function deployToLocalNet() {
    // deploy uniswap
    // deploy WETH
    // deploy factory
    // deploy token
}


module.exports = async function (deployer, _network, accounts) {
    return await deployer.deploy(Migrations);
};
