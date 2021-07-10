// const account = process.argv[2];
// if (!account) {
//     console.error("account wasn't provided");
//     process.exit(1);
// }

const fs = require('fs');
const HDWalletProvider = require('@truffle/hdwallet-provider');
const ethers = require('ethers');

const mnemonic = fs.readFileSync(".secret").toString().trim();
const wallet = ethers.Wallet.fromMnemonic(mnemonic);
const Web3 = require('web3');
const provider = new HDWalletProvider(
    mnemonic,
    'https://bsc-dataseed1.binance.org',
);
const account = wallet.connect(new ethers.providers.Web3Provider(provider));

const token = new ethers.Contract(
    '0xb6b98291Ccd982f9655a3DCAfED808135c325f8b',
    ['function holdersRewarded(uint256 index) public view returns (address)',
        'function totalHolders() public view returns (uint256)',
        'function balanceOf(address holder)public view returns(uint256)'],
    account
);

const bn = (n) => {
    return Web3.utils.toBN(n.toString());
}

const run = async () => {
    // big.js
    let iter = bn(0);
    const one = bn(1);
    const totalCount = await token.totalHolders();
    console.log("total holders", totalCount.toString());

    fs.appendFile('holders.csv', 'index, address, balance\n', function (err) {
        if (err) {
            console.error(err);
            process.exit(1);
        };
    });
    while (iter.lte(bn(totalCount))) {
        console.log("fetch holder", iter.toString());
        const holder = await token.holdersRewarded(iter.toString());
        const balance = await token.balanceOf(holder.toString());
        fs.appendFile('holders.csv', `${iter.toString()}, ${holder.toString()}, ${balance.toString()}\n`,
            function (err) {
                if (err) {
                    console.error(err);
                    process.exit(1);
                };
            });
        iter = iter.add(one);
    }
    console.log("finished");
    process.exit(0);
};

run();