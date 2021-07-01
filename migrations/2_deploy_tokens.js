const web3 = require('web3');
const HungryPanda = artifacts.require("HungryPanda");
const PeriodicEscrow = artifacts.require("PeriodicEscrow");


async function deployEscrowContracts(
  deployer,
  admin,
  addresses,
  openAfterSeconds,
  periodSeconds) {

  const mapping = {};
  for (let i = 0; i < addresses.length; i++) {
    const address = addresses[i];
    console.log("deploy escrow for", address);
    await deployer.deploy(PeriodicEscrow, address,
      openAfterSeconds, periodSeconds, { from: admin });
    mapping[address] = await PeriodicEscrow.deployed();
  }
  return mapping;
}

function splitAccounts(accounts, position) {
  return {
    core: accounts.slice(0, position),
    rest: accounts.slice(position)
  }
}

async function deployToken(deployer, admin, router, wallet) {
  await deployer.deploy(HungryPanda, router, wallet, { from: admin });
  return await HungryPanda.deployed();
}

async function transferAndLockTokens(token, admin, mapping, amount, parts = 1) {
  const addresses = Object.keys(mapping);
  const partAmount = amount.div(web3.utils.toBN(addresses.length)).toString();
  for (let index = 0; index < addresses.length; index++) {
    const recipient = addresses[index];
    const escrow = mapping[recipient];
    // transfer to escrow contract 
    await token.excludeFromFee(escrow.address, { from: admin });
    await token.transfer(escrow.address, partAmount, { from: admin });
    await token.includeToFee(escrow.address, { from: admin });
    await escrow.setToken(token.address, partAmount, parts, { from: admin });
  }
}

async function deploy(deployer, router, admin, coreTeam, restTeam) {
  console.log("Deploy core team's escrow contracts");
  // first withdrawal after 30 days
  const coreTeamContracts = await deployEscrowContracts(deployer, admin, coreTeam, 0, 2592000); // once per 30 days
  console.log("Deploy rest of the team's escrow contracts");
  // unlocked after 10 months with withdrawal after 1 second
  const restTeamContracts = await deployEscrowContracts(deployer, admin, restTeam, 25920000, 1);
  // deploy token ...
  const token = await deployToken(deployer, admin, router, admin);
  // transfer tokens to contracts
  const totalSupply = await token.totalSupply({ from: admin });
  // transfer tokens to core team escrow contracts
  await transferAndLockTokens(token,
    admin,
    coreTeamContracts,
    web3.utils.toBN(totalSupply.toString()).div(web3.utils.toBN('20')),
    5);
  // transfer tokens to rest team escrow contracts
  await transferAndLockTokens(token,
    admin,
    restTeamContracts,
    web3.utils.toBN(totalSupply.toString()).div(web3.utils.toBN('20')), 5);

  return deployer;
}


module.exports = async function (deployer, _network, accounts) {
  let { core, rest, admin, router } = (() => {
    let o = {};
    switch (_network) {
      case "develop":
        o = splitAccounts(accounts, 5)
        return {
          core: o.core,
          rest: o.rest,
          admin: accounts[1],
          router: 'TODO'
        };
      case "bscTestnet":
        o = splitAccounts(accounts, 5)
        return {
          core: o.core,
          rest: o.rest,
          admin: accounts[1],
          router: '0xD99D1c33F9fC3444f8101754aBC46c52416550D1'
        };
      case "bscMainnet":
        return {
          core: [],
          rest: [],
          admin: accounts[0],
          router: '0x10ED43C718714eb63d5aA57B78B54704E256024E'
        };

    }
  })();

  console.log(core, rest, admin, router);

  return await deploy(
    deployer,
    router,
    admin,
    core,
    rest);
};
