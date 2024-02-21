// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideBaseTestHelper} from "../AsideBaseTestHelper.t.sol";

abstract contract AreAllUnlocked is AsideBaseTestHelper {
    function test_areAllUnlocked_WhenLocked() public {
        assertFalse(baseToken.areAllUnlocked());
    }

    function test_areAllUnlocked_WhenEmergencyUnlockHasBeenTriggered() public {
        vm.prank(admin);
        baseToken.eUnlock();
        assertTrue(baseToken.areAllUnlocked());
    }

    function test_areAllUnlocked_WhenTimelockDeadlineHasBeenReached() public {
        _reachTimelockDeadline();
        assertTrue(baseToken.areAllUnlocked());
    }
}
