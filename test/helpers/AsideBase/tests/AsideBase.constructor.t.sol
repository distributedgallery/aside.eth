// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideBaseTestHelper} from "../AsideBaseTestHelper.t.sol";

abstract contract Constructor is AsideBaseTestHelper {
    function test_constructor() public mint {
        assertTrue(baseToken.hasRole(baseToken.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(baseToken.hasRole(baseToken.MINTER_ROLE(), minter));
        assertEq(baseToken.TIMELOCK_DEADLINE(), block.timestamp + timelock);
    }
}
