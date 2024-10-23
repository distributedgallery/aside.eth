// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x05, AsideChainlink, AsideBase, Aside0x05TestHelper} from "./Aside0x05TestHelper.t.sol";
import {AsideBaseTest} from "../helpers/AsideBase/tests/AsideBase.t.sol";

contract Aside0x05BaseTest is Aside0x05TestHelper, AsideBaseTest {
    // #region NB_OF_TOKENS
    function test_NB_OF_TOKENS() public {
        assertEq(baseToken.NB_OF_TOKENS(), 100);
    }
    // #endregion

    // #region unlock
    function test_RevertWhen_unlock() public mint {
        vm.expectRevert(abi.encodeWithSelector(Aside0x05.DisabledFunction.selector));
        baseToken.unlock(_tokenIds());
    }
    // #endregion

    // #region isUnlocked
    function test_isUnlocked_WhenHarrisHasBeenElected() public {
        for (uint256 i = 0; i <= 93; i++) {
            _mint(i);
        }

        _update();
        router.fulfillRequest(token, abi.encodePacked(uint256(0)), "");

        for (uint256 i = 0; i <= 46; i++) {
            assertTrue(token.isUnlocked(i));
        }
        for (uint256 j = 47; j <= 93; j++) {
            assertFalse(token.isUnlocked(j));
        }

        assertTrue(token.isUnlocked(94));
        assertTrue(token.isUnlocked(95));
        assertTrue(token.isUnlocked(96));

        assertFalse(token.isUnlocked(97));
        assertFalse(token.isUnlocked(98));
        assertFalse(token.isUnlocked(99));
    }

    function test_isUnlocked_WhenTrumpHasBeenElected() public {
        for (uint256 i = 0; i <= 93; i++) {
            _mint(i);
        }

        _update();
        router.fulfillRequest(token, abi.encodePacked(uint256(1)), "");

        for (uint256 i = 0; i <= 46; i++) {
            assertFalse(token.isUnlocked(i));
        }
        for (uint256 j = 47; j <= 93; j++) {
            assertTrue(token.isUnlocked(j));
        }

        assertFalse(token.isUnlocked(94));
        assertFalse(token.isUnlocked(95));
        assertFalse(token.isUnlocked(96));

        assertTrue(token.isUnlocked(97));
        assertTrue(token.isUnlocked(98));
        assertTrue(token.isUnlocked(99));
    }

    function test_isUnlocked_WhenNoOneHasBeenElected() public {
        for (uint256 i = 0; i <= 93; i++) {
            _mint(i);
        }

        for (uint256 i = 0; i <= 99; i++) {
            assertFalse(token.isUnlocked(i));
        }
    }

    function test_isUnlocked_WhenTokenHasBeenBurntAndReminted() public mint setUpUnlockConditions(0) {
        vm.prank(owner);
        baseToken.burn(tokenId);
        _mint();
        assertTrue(baseToken.isUnlocked(tokenId));
    }

    function test_isUnlocked_WhenTokenHasBeenUnlockedAndTransfered() public mint setUpUnlockConditions(0) {
        vm.prank(owner);
        baseToken.transferFrom(owner, recipient, tokenId);
        assertTrue(baseToken.isUnlocked(tokenId));
    }
    // #endregion

    // #region overrides
    function test_RevertWhen_unlock_ForNonexistentToken() public virtual override {}

    function test_RevertWhen_unlock_ForAlreadyUnlockedToken() public virtual override {}
    // #endregion
}
