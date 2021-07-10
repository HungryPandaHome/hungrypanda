// SPDX-License-Identifier: MIT
pragma solidity >=0.8.6 <0.9.0;

import "./IERC20.sol";

interface IMigrateToken is IERC20 {
    function maxTxAmount() external view returns (uint256);

    function minimalSupply() external view returns (uint256);

    function numTokensSellToAddLiquidity() external view returns (uint256);

    function totalHolders() external view returns (uint256);

    function holdersRewarded(uint256 index) external view returns (address);
}
