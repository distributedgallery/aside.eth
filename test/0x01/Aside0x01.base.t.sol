// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideChainlink, AsideBase, Aside0x01TestHelper} from "./Aside0x01TestHelper.t.sol";
import {AsideBaseTest} from "../helpers/AsideBase/tests/AsideBase.t.sol";

contract Aside0x01BaseTest is Aside0x01TestHelper, AsideBaseTest {
    // #region unlock
    function test_unlock() public mint setUpUnlockConditions {
        vm.expectEmit(address(baseToken));
        emit AsideBase.Unlock(tokenId);
        baseToken.unlock(_tokenIds());

        assertTrue(baseToken.isUnlocked(tokenId));
    }
    // #endregion

    // #region isUnlocked
    function test_isUnlocked_WhenRegularUnlockHasBeenTriggered() public mint setUpUnlockConditions {
        token.unlock(_tokenIds());
        assertTrue(token.isUnlocked(tokenId));
    }

    function test_isUnlocked_WhenTokenHasBeenBurntAndReminted() public mint setUpUnlockConditions {
        token.unlock(_tokenIds());
        vm.prank(owner);
        baseToken.burn(tokenId);
        _mint();
        assertFalse(baseToken.isUnlocked(tokenId));
    }

    function test_isUnlocked_WhenTokenHasBeenUnlockedAndTransfered() public mint setUpUnlockConditions {
        token.unlock(_tokenIds());
        vm.prank(owner);
        baseToken.transferFrom(owner, recipient, tokenId);
        assertTrue(baseToken.isUnlocked(tokenId));
    }
    // #endregion

    // #region mint
    function test_mint_RegularTokensAreLocked() public mint {
        uint256 NB_OF_TOKENS = token.NB_OF_TOKENS();
        vm.prank(minter);
        token.mint(owner, NB_OF_TOKENS - 1);

        assertFalse(token.isUnlocked(tokenId));
        assertFalse(token.isUnlocked(NB_OF_TOKENS - 1));
    }
    // #endregion

    // #region unlock
    function test_RevertWhen_unlock_WithDeprecatedData() public mint setUpUnlockConditions {
        vm.warp(block.timestamp + 1 hours + 1);
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.DeprecatedData.selector));
        baseToken.unlock(_tokenIds());
    }

    function test_RevertWhen_unlock_WithInvalidSentiment() public mint update {
        router.fulfillRequest(token, abi.encodePacked(sentiment + token.SENTIMENT_INTERVAL()), "");
        vm.expectRevert(abi.encodeWithSelector(AsideBase.InvalidUnlock.selector, tokenId));
        baseToken.unlock(_tokenIds());
    }
    // #endregion
}
