// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper} from "./Aside0x01Helper.sol";

/**
 * Returns the number of tokens in `owner`'s account.
 */
contract BalanceOf is TestHelper {
    function test_BalanceOf() public mint {
        assertEq(token.balanceOf(owner), 1);
    }
}
