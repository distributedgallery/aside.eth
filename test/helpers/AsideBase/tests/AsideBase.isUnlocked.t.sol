// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideBaseTestHelper, IERC721Errors} from "../AsideBaseTestHelper.t.sol";

abstract contract IsUnlocked is AsideBaseTestHelper {
    function test_isUnlocked_WhenLocked() public mint {
        assertFalse(baseToken.isUnlocked(tokenId));
    }

    function test_isUnlocked_WhenEmergencyUnlockHasBeenTriggered() public mint {
        vm.prank(admin);
        baseToken.eUnlock();
        assertTrue(baseToken.isUnlocked(tokenId));
    }

    function test_isUnlocked_WhenTimelockDeadlineHasBeenReached() public mint {
        _reachTimelockDeadline();
        assertTrue(baseToken.isUnlocked(tokenId));
    }

    function test_RevertWhen_isUnlocked_ForNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        baseToken.isUnlocked(tokenId);
    }
}
