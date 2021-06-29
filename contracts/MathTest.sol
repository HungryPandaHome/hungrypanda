// SPDX-License-Identifier: MIT

pragma solidity >=0.8.6 <0.9.0;


contract TestMath {
    uint256 private constant DECIMALFACTOR  = 10 ** 9;
    
    // 1 000 000 000 000 000 000 000
    function portion(uint256 total, uint256 balance, uint256 reward) external pure returns (uint256){
        total /= DECIMALFACTOR;
        // 1 000 000 000 000
        uint256 denominator = total / balance;
        // 500
        return reward / denominator;
    }
}