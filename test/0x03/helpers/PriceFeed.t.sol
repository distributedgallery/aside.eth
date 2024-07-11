// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract PriceFeed {
    int256 public constant PRICE_LIMIT = 1_000_000_000_000;
    bool public priced = false;

    function unlock() public {
        priced = true;
    }

    function lock() public {
        priced = false;
    }

    function latestRoundData() public view returns (uint80, int256, uint256, uint256, uint80) {
        if (priced) return (0, PRICE_LIMIT, 0, 0, 0);
        else return (0, PRICE_LIMIT - 1, 0, 0, 0);
    }
}
