// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper} from "./Aside0x01Helper.t.sol";

/**
 * Reviewed: OK.
 */
contract AreAllUnlocked is TestHelper {
    function test_areAllUnlocked_WhenLocked() public {
        assertFalse(token.areAllUnlocked());
    }

    function test_areAllUnlocked_WhenEmergencyUnlockHasBeenTriggered() public {
        vm.prank(admin);
        token.unlock();
        assertTrue(token.areAllUnlocked());
    }

    function test_areAllUnlocked_WhenLockDeadlineHasBeenReached() public {
        _unlock();
        assertTrue(token.areAllUnlocked());
    }
}
