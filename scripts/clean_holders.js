const fs = require('fs');
const readline = require('readline');
const Web3 = require('web3');

const filter = {};

const lineReader = require('readline').createInterface({
    input: require('fs').createReadStream('holders.csv')
});

const bn = (n) => {
    return Web3.utils.toBN(n.toString());
}

let count = -1;
const decimalFactor = bn(10).pow(bn(18));

console.log(decimalFactor);

lineReader.on('line', function (line) {
    count++;
    if (count <= 0) {
        return;
    }
    let [_, address, balance] = line.split(",");
    address = address.trim();
    balance = balance.trim();
    if (filter[address]) {
        console.log("found duplicate: ", address, balance, filter[address]);
        return
    }
    if (bn(balance).div(decimalFactor).lte(bn('0'))) {
        console.log("balance to low: ", address, balance);
        return
    }
    filter[address] = balance;
});

lineReader.on('close', () => {
    Object.keys(filter).forEach(address => {
        fs.appendFile('holders.clean.csv',
            `${address}, ${filter[address]}\n`,
            function (err) {
                if (err) {
                    console.error(err);
                    process.exit(1);
                };
            });
    });
});