const HungryPanda = artifacts.require("HungryPanda");

function deployToLocalNet() {
    // deploy uniswap
    // deploy WETH
    // deploy factory
    // deploy token
}


  // TODO: deploy escrows ...
  // TODO: deploy token ...
  // TODO: transfer tokens to escrows ...
  // TODO: set token for escrow ...
  
module.exports = async function (deployer, _network, accounts) {
    switch (_network){}
    
    return await deployer.deploy(Migrations);
};
