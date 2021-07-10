// SPDX-License-Identifier: MIT

pragma solidity >=0.8.6 <0.9.0;

import "./IERC20.sol";
import "../security/Ownable.sol";

interface IUniswapV2Factory {
    function createPair(address token1, address token2)
        external
        returns (address);
}
