// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Aside0x01TestHelper, Aside0x01, AsideChainlink, AsideBase, AsideBaseTestHelper, IAccessControl} from "./Aside0x01TestHelper.t.sol";
import {AsideBaseTest} from "../helpers/AsideBase/tests/AsideBase.t.sol";

contract Aside0x01BaseTest is Aside0x01TestHelper, AsideBaseTest {
    function _mint() internal override(Aside0x01TestHelper, AsideBaseTestHelper) {
        super._mint();
    }

    function _mint(address to) internal override(Aside0x01TestHelper, AsideBaseTestHelper) {
        super._mint(to);
    }

    function _setUpUnlockConditions() internal override(Aside0x01TestHelper, AsideBaseTestHelper) {
        super._setUpUnlockConditions();
    }

    function test_mint_WithPayload() public mint {
        assertEq(token.sentimentOf(tokenId), sentiment);
    }

    function test_mint_WithoutPayload() public {
        vm.expectRevert(abi.encodeWithSelector(AsideBase.InvalidPayload.selector, ""));
        vm.prank(minter);
        baseToken.mint(owner, 1);
    }

    function test_RevertWhen_mint_WithInvalidPayload() public {
        vm.expectRevert(abi.encodeWithSelector(AsideBase.InvalidPayload.selector, ""));
        vm.prank(minter);
        baseToken.mint(owner, 1, "");

        vm.expectRevert(abi.encodeWithSelector(AsideBase.InvalidPayload.selector, "11"));
        vm.prank(minter);
        baseToken.mint(owner, 1, "11");

        vm.expectRevert(abi.encodeWithSelector(AsideBase.InvalidPayload.selector, "1111"));
        vm.prank(minter);
        baseToken.mint(owner, 1, "1111");

        vm.expectRevert(abi.encodeWithSelector(AsideBase.InvalidPayload.selector, "a3c"));
        vm.prank(minter);
        baseToken.mint(owner, 1, "a3c");

        vm.expectRevert(abi.encodeWithSelector(Aside0x01.InvalidSentiment.selector));
        vm.prank(minter);
        baseToken.mint(owner, 1, "101");
    }

    function test_RevertWhen_mint_FromUnauthoried() public mint {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), baseToken.MINTER_ROLE())
        );
        baseToken.mint(owner, 1, "060");
    }

    function test_isUnlocked_WhenRegularUnlockHasBeenTriggered() public mint update {
        router.fulfillRequest(token, abi.encodePacked(sentiment), "");
        token.unlock(_tokenIds());
        assertTrue(token.isUnlocked(tokenId));
    }

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
}
