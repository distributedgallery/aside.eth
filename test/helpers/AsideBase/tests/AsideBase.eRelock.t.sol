// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideBaseTestHelper, IAccessControl} from "../AsideBaseTestHelper.t.sol";

abstract contract ERelock is AsideBaseTestHelper {
    function test_eRelock() public {
        vm.prank(admin);
        baseToken.eUnlock();
        assertTrue(baseToken.isEUnlocked());

        vm.expectEmit(true, true, true, true);
        emit EmergencyUnlock(false);
        vm.prank(admin);
        baseToken.eRelock();
        assertFalse(baseToken.isEUnlocked());
    }

    function test_RevertWhen_eRelock_FromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), baseToken.DEFAULT_ADMIN_ROLE())
        );
        baseToken.eRelock();
    }
}
