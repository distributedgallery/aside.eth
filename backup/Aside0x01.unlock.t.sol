// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper, IAccessControl} from "./Aside0x01Helper.t.sol";

/**
 * Reviewed: OK.
 */
contract Unlock is TestHelper {
    function test_unlock() public {
        vm.expectEmit(true, true, true, true);
        emit EmergencyUnlock(true);
        vm.prank(admin);
        token.unlock();
        assertTrue(token.eUnlocked());
    }

    function test_RevertWhen_unlockFromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), bytes32(0))
        );
        token.unlock();
    }
}
