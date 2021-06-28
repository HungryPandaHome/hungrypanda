const Migrations = artifacts.require("Migrations");




module.exports = async function (deployer) {
  return await deployer.deploy(Migrations);
};
