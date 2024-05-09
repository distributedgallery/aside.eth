// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideBaseTestHelper, IAccessControl} from "../AsideBaseTestHelper.t.sol";

abstract contract EUnlock is AsideBaseTestHelper {
    function test_eUnlock() public {
        vm.expectEmit(address(baseToken));
        emit EmergencyUnlock();
        vm.prank(admin);
        baseToken.eUnlock();
        assertTrue(baseToken.isEUnlocked());
    }

    function test_RevertWhen_eUnlock_FromUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), baseToken.DEFAULT_ADMIN_ROLE())
        );
        baseToken.eUnlock();
    }
}
