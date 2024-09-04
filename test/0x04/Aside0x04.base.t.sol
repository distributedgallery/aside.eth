// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x04, AsideChainlink, AsideBase, Aside0x04TestHelper} from "./Aside0x04TestHelper.t.sol";
import {AsideBaseTest} from "../helpers/AsideBase/tests/AsideBase.t.sol";

contract Aside0x04BaseTest is Aside0x04TestHelper, AsideBaseTest {
    // #region NB_OF_TOKENS
    function test_NB_OF_TOKENS() public {
        assertEq(baseToken.NB_OF_TOKENS(), 36);
    }
    // #endregion

    // #region unlock
    function test_RevertWhen_unlock() public mint setUpUnlockConditions {
        vm.expectRevert(abi.encodeWithSelector(Aside0x04.DisabledFunction.selector));
        baseToken.unlock(_tokenIds());
    }
    // #endregion

    // #region isUnlocked
    function test_isUnlocked_WhenRegularUnlockHasBeenTriggered() public mint setUpUnlockConditions {
        assertTrue(token.isUnlocked(tokenId));
    }

    function test_isUnlocked_WhenTokenHasBeenBurntAndReminted() public mint setUpUnlockConditions {
        vm.prank(owner);
        baseToken.burn(tokenId);
        _mint();
        assertTrue(baseToken.isUnlocked(tokenId));
    }

    function test_isUnlocked_WhenTokenHasBeenUnlockedAndTransfered() public mint setUpUnlockConditions {
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
