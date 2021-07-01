const web3 = require('web3');
const fs = require('fs');
const HungryPanda = artifacts.require("HungryPanda");
const Airdrop = artifacts.require("Airdrop");
const PeriodicEscrow = artifacts.require("PeriodicEscrow");

const deploymentObject = {};
let escrowIndex = 0;

async function deployEscrowContracts(
  deployer,
  admin,
  addresses,
  openAfterSeconds,
  periodSeconds) {

  const mapping = {};
  for (let i = 0; i < addresses.length; i++, escrowIndex++) {
    const address = addresses[i];
    console.log("deploy escrow for", address);
    await deployer.deploy(PeriodicEscrow, address,
      openAfterSeconds, periodSeconds, { from: admin });
    const escrow = await PeriodicEscrow.deployed();
    mapping[address] = escrow;
    deploymentObject[`escrow${escrowIndex}`] = [address, escrow.address];
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
  console.log("Pancake: ", router);
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
    console.log(`excluding ${escrow.address} from fee...`);
    await token.excludeFromFee(escrow.address, { from: admin });
    await token.transfer(escrow.address, partAmount, { from: admin });
    await token.includeToFee(escrow.address, { from: admin });
    console.log(`including ${escrow.address} into fee...`);
    await escrow.setToken(token.address, partAmount, parts, { from: admin });
  }
}

let airdropIndex = 0;
async function processAirdrop(deployer, token, admin, amount, startsAfter) {
  await deployer.deploy(Airdrop, admin, startsAfter, { from: admin });
  const airdrop = await Airdrop.deployed();
  await token.excludeFromFee(airdrop.address, { from: admin });
  await token.transfer(airdrop.address, amount);
  // airdrop is excluded from rewards ...
  await airdrop.setToken(token.address, amount);
  deploymentObject[`airdrop${airdropIndex}`] = airdrop.address;
  airdropIndex++;
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
  deploymentObject['token'] = token.address;
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
  // deploy airdrop contracts ...
  await processAirdrop(deployer,
    token,
    admin,
    web3.utils.toBN(totalSupply.toString()).div(web3.utils.toBN('100')), // 1 percent
    2592000); // after 30 days ...
  await processAirdrop(deployer,
    token,
    admin,
    web3.utils.toBN(totalSupply.toString()).div(web3.utils.toBN('100')), // 1 percent
    2592000 * 2); // after 60 days ...

  fs.writeFileSync("deployment.json", JSON.stringify(deploymentObject));

  return deployer;
}


module.exports = async function (deployer, _network, accounts) {
  let { core, rest, admin, router } = (() => {
    let o = {};
    switch (_network) {
      case "develop":
      case "development":
        const deployment = JSON.parse(fs.readFileSync(__dirname + "/../pandaswap-dex/deployment.json",
          { encoding: 'utf-8' }));
        o = splitAccounts(accounts, 5)
        return {
          core: o.core,
          rest: o.rest,
          admin: accounts[0],
          router: deployment.router,
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

  return await deploy(
    deployer,
    router,
    admin,
    core,
    rest);
};
