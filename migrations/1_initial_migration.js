const Migrations = artifacts.require("Migrations");

module.exports = async function (deployer, _network, accounts) {
  return await deployer.deploy(Migrations, { from: accounts[1] });
};
