// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper, IERC721Errors} from "./Aside0x01Helper.t.sol";

/**
 * Reviewed: OK.
 */
contract IsUnlocked is TestHelper {
    function test_isUnlocked_WhenLocked() public mint {
        assertFalse(token.isUnlocked(tokenId));
    }

    function test_isUnlocked_WhenRegularUnlockHasBeenTriggered() public mint {
        token.requestUnlock(tokenId);
        router.fulfillRequest(token, router.REQUEST_ID(), abi.encodePacked(sentiment), "");
        assertTrue(token.isUnlocked(tokenId));
    }

    function test_isUnlocked_WhenEmergencyUnlockHasBeenTriggered() public mint {
        vm.prank(admin);
        token.unlock();
        assertTrue(token.isUnlocked(tokenId));
    }

    function test_isUnlocked_WhenLockDeadlineHasBeenReached() public mint {
        _unlock();
        assertTrue(token.isUnlocked(tokenId));
    }

    function test_RevertWhen_isUnlockedForNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        token.isUnlocked(tokenId);
    }
}
