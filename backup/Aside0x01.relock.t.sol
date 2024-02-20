// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper, IAccessControl} from "./Aside0x01Helper.t.sol";

/**
 * Reviewed: OK.
 */
contract Relock is TestHelper {
    function test_relock() public {
        vm.prank(admin);
        token.unlock();
        assertTrue(token.eUnlocked());

        vm.expectEmit(true, true, true, true);
        emit EmergencyUnlock(false);
        vm.prank(admin);
        token.relock();
        assertFalse(token.eUnlocked());
    }

    function test_RevertWhen_relockFromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), bytes32(0))
        );
        token.relock();
    }
}
