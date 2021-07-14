const vorpal = require('vorpal')();
const fs = require('fs');
const readline = require('readline');
const HDWalletProvider = require('@truffle/hdwallet-provider');
const ethers = require('ethers');
const mnemonic = fs.readFileSync(".secret").toString().trim();
const wallet = ethers.Wallet.fromMnemonic(mnemonic);
const Web3 = require('web3');

const bn = (n) => {
    return Web3.utils.toBN(n.toString());
}
const testRpc = 'https://data-seed-prebsc-1-s1.binance.org:8545';

vorpal
    .command('transfer', 'Copy holders from list to token')
    .option('-a, --address <addr>', 'Destination token address')
    .option('-u, --rpc <url>', 'Network rpc url')
    .option('-f, --file <path>', 'Holders list CSV file path')
    .types({
        string: ['a', 'address', 'u', 'rpc', 'f', 'file'],
    })
    .validate(function (args) {
        let { address, file } = args.options;
        if (!address) {
            return `transfer: token address must be known`;
        }
        if (!file) {
            return `transfer: file path must be known`;
        }
        return true
    })
    .action(async function (args, callback) {
        const ctx = this;
        let { address, rpc, file } = args.options;
        if (!rpc) {
            this.log(`transfer: rpc not set, using testnet as default`);
            rpc = testRpc;
        }
        const provider = new HDWalletProvider(
            mnemonic,
            rpc,
        );
        const account = wallet.connect(new ethers.providers.Web3Provider(provider));
        const token = new ethers.Contract(
            address,
            ['function excludeFromFee(address _address) public',
                'function setSwapAndLiquifyEnabled(bool _enabled) public',
                'function includeToFee(address _address) public',
                'function balanceOf(address holder) public view returns(uint256)',
                'function transfer(address _recipient, uint256 _amount) public'],
            account
        );
        const job = new Promise((resolve, reject) => {
            const lineReader = readline.createInterface({
                input: fs.createReadStream(file)
            });
            const store = [];
            lineReader.on('line', async (line) => {
                let [_, address, balance] = line.split(",");
                address = address.trim();
                balance = bn(balance.trim());
                store.push({ address, balance });
            });
            lineReader.on('close', () => {
                ctx.log("transfer: finished");
                resolve(store);
            });
        })
        const holders = await job;
        // const addresses = Object.keys(holders);
        let a, b;
        ctx.log(`transfer: disable swap`);
        await token.setSwapAndLiquifyEnabled(false);
        for (i = 0; i < holders.length; i++) {
            a = holders[i].address;
            b = holders[i].balance;
            if (b.lte(bn(0))) {
                continue
            }
            ctx.log(`transfer ${i}: transfer ${b} tokens to ${a}`);
            await token.transfer(a, b.toString());
            ctx.log(`transfer ${i}: exclude from fee ${a}`);
            try {
                await token.excludeFromFee(a);
            } catch (error) {
                console.log(error.message);
            }

            // ctx.log(`transfer: include ${a}`);
            // await token.includeToFee(a);
        }
        callback();
    });

vorpal
    .delimiter('panda$')
    .show();