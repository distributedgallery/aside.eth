// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper} from "./Aside0x01Helper.sol";

contract BalanceOf is TestHelper {
    function test_balanceOf() public {
        vm.prank(owners[2]);
        moveToUnlock();
        token.transferFrom(owners[2], owners[0], 2);

        assertEq(token.balanceOf(owners[0]), 2);
        assertEq(token.balanceOf(owners[1]), 1);
        assertEq(token.balanceOf(owners[2]), 0);
    }
}
