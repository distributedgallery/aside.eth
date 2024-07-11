// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x03TestHelper, Aside0x03, IERC721Errors} from "./Aside0x03TestHelper.t.sol";

contract Unlock is Aside0x03TestHelper {
    function test_unlock() public mint {
        assertFalse(baseToken.areAllUnlocked());
        assertFalse(baseToken.isUnlocked(tokenId));

        feed.unlock();
        vm.expectEmit(address(token));
        emit Unlock();
        token.unlock();

        assertTrue(baseToken.areAllUnlocked());
        assertTrue(baseToken.isUnlocked(tokenId));

        // check whether tokens are still unlocked after a transfer
        vm.prank(owner);
        baseToken.transferFrom(owner, recipient, tokenId);
        assertTrue(baseToken.areAllUnlocked());
        assertTrue(baseToken.isUnlocked(tokenId));
    }

    function test_RevertWhen_unlock_WhenAlreadyUnlocked() public {
        feed.unlock();
        token.unlock();

        vm.expectRevert(abi.encodeWithSelector(Aside0x03.AlreadyUnlocked.selector));
        token.unlock();
    }

    function test_RevertWhen_unlock_WhenPriceIsBelowPriceLimit() public {
        vm.expectRevert(abi.encodeWithSelector(Aside0x03.InvalidPrice.selector));
        token.unlock();
    }
}
