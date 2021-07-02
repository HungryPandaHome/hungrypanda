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
    rest: accounts.slice(position, 5),
    salary: accounts.slice(position + 5)
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
  await token.transfer(airdrop.address, amount, { from: admin });
  // airdrop is excluded from rewards ...
  await airdrop.setToken(token.address, amount, { from: admin });
  deploymentObject[`airdrop${airdropIndex}`] = airdrop.address;
  airdropIndex++;
}

const toBN = (n) => {
  return web3.utils.toBN(n.toString());
}

async function deploy(deployer, router, admin, coreTeam, restTeam, salaryList, supportWallet) {
  console.log("Deploy core team's escrow contracts");
  // first withdrawal after 30 days
  const salaryContracts = await deployEscrowContracts(deployer, admin, salaryList,
    0, 2592000); // once per 30 days
  console.log("Deploy rest of the team's escrow contracts");
  // unlocked after 10 months with withdrawal after 1 second
  const lockedContracts = await deployEscrowContracts(deployer, admin, [...coreTeam, ...restTeam], 25920000, 1);
  // deploy token ...
  const token = await deployToken(deployer, admin, router, supportWallet);
  deploymentObject['token'] = token.address;
  // transfer tokens to contracts
  const totalSupply = await token.totalSupply({ from: admin });

  // transfer tokens to team salary escrow contracts
  const granularity = toBN('100');
  await transferAndLockTokens(token,
    admin,
    salaryContracts,
    toBN(toBN(totalSupply)).div(granularity).mul(toBN(5)),
    5);

  // transfer tokens to rest team escrow contracts
  const restTeamContracts = {};
  restTeam.forEach(address => {
    restTeamContracts[address] = lockedContracts[address];
  });
  await transferAndLockTokens(token,
    admin,
    restTeamContracts,
    toBN(totalSupply).div(granularity), 1);

  const coreTeamContracts = {};
  coreTeam.forEach(address => {
    coreTeamContracts[address] = lockedContracts[address];
  });
  await transferAndLockTokens(token,
    admin,
    coreTeamContracts,
    toBN(totalSupply).div(granularity).mul(toBN(4)), 1);

  // deploy airdrop contracts ...
  await processAirdrop(deployer,
    token,
    admin,
    toBN(totalSupply).div(granularity), // 1 percent
    2592000); // after 30 days ...
  await processAirdrop(deployer,
    token,
    admin,
    toBN(totalSupply).div(granularity), // 1 percent
    2592000 * 2); // after 60 days ...

  fs.writeFileSync("deployment.json", JSON.stringify(deploymentObject));

  return deployer;
}


module.exports = async function (deployer, _network, accounts) {
  let { core, rest, salary, admin, router, support } = (() => {
    let o = {};
    switch (_network) {
      case "develop":
      case "development":
        const deployment = JSON.parse(fs.readFileSync(__dirname + "/../pandaswap-dex/deployment.json",
          { encoding: 'utf-8' }));
        o = splitAccounts(accounts, 3)
        return {
          core: o.core,
          rest: o.rest,
          salary: o.salary,
          admin: accounts[0],
          support: accounts[1],
          router: deployment.router,
        };
      case "bscTestnet":
        o = splitAccounts(accounts, 3)
        return {
          core: o.core,
          rest: o.rest,
          salary: o.salary,
          admin: accounts[0],
          support: accounts[1],
          router: '0xD99D1c33F9fC3444f8101754aBC46c52416550D1'
        };
      case "bscMainnet":
        return {
          core: [
            '0xf15B6cFA25748d4268edF62dce1EaA7f3bEeb7a7',
            '0xf694dFA5763FC6aF4CcDaC53340C006b534C7Aa1',
            '0x668B40D03DA3f426549F340bc10494a7071532Ae',
            '0xe58eC7d88Afa48155c322b7B6bF7177738bb3286',
            '0x038d9bEDbeBa8927b961DE82db059d45bCF0CBeD',
            '0x17662fb2aa310FE24b209C05dB100918fB222573'],
          rest: [
            '0x90490F092814DFf1A61302f6b270E9834eC2Cd17',
            '0x929EC1ADcc1deccA76e12e3901A654C5E96043ac',
            '0xFA97A244C68993B23feAFbf5e30a06C5F889E597',
            '0xD9D7901b8653aAec03Ce91e6dCf0a30415aaA834'],
          salary: [
            '0x3856739b6434e0D8B6AD7eB885D9F0876312b15F',
            '0x4d2e151682CdE415C0E81841f68cfCED3FA4266B',
            '0x61b8dFbdcF65C94656DEF6632DD8Df4fbA96c938',
            '0xfC49bb278de0296173F47d6Ca00eCe712F09e84E',
            '0x7f07356E13BA3306319748f148487Be05b34dBAd'
          ],
          admin: accounts[0],
          support: '0x4d2e151682CdE415C0E81841f68cfCED3FA4266B',
          router: '0x10ED43C718714eb63d5aA57B78B54704E256024E'
        };

    }
  })();

  return await deploy(
    deployer,
    router,
    admin,
    core,
    rest,
    salary,
    support);
};
