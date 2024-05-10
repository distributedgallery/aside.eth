// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AsideChainlink, AsideBase, Aside0x01TestHelper, AsideBaseTestHelper} from "./Aside0x01TestHelper.t.sol";
import {AsideBaseTest} from "../helpers/AsideBase/tests/AsideBase.t.sol";

contract Aside0x01BaseTest is Aside0x01TestHelper, AsideBaseTest {
    // #region required overrides
    function _mint() internal override(Aside0x01TestHelper, AsideBaseTestHelper) {
        super._mint();
    }

    function _mint(address to) internal override(Aside0x01TestHelper, AsideBaseTestHelper) {
        super._mint(to);
    }

    function _setUpUnlockConditions() internal override(Aside0x01TestHelper, AsideBaseTestHelper) {
        super._setUpUnlockConditions();
    }
    // #endregion

    // #region mint
    function test_mint() public mint {
        assertEq(token.sentimentOf(tokenId), sentiment);
    }

    function test_mint_WithoutPayload() public {
        vm.prank(minter);
        baseToken.mint(owner, tokenId);
        assertEq(token.sentimentOf(tokenId), 0);
    }

    function test_RevertWhen_mint_WithInvalidPayload() public {
        vm.expectRevert(abi.encodeWithSelector(AsideBase.InvalidPayload.selector, abi.encodePacked(uint256(101))));
        vm.prank(minter);
        baseToken.mint(owner, 1, abi.encodePacked(uint256(101)));
    }
    // #endregion

    // #region isUnlocked
    function test_isUnlocked_WhenRegularUnlockHasBeenTriggered() public mint setUpUnlockConditions {
        token.unlock(_tokenIds());
        assertTrue(token.isUnlocked(tokenId));
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
