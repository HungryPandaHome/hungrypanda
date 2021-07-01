// SPDX-License-Identifier: MIT

pragma solidity >=0.8.6 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20 {
    constructor(uint256 _totalSupply) ERC20("TestERC20", "TRC") {
        _mint(msg.sender, _totalSupply * 10**decimals());
    }
}
