// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Aside0x01, AsideChainlink, AsideBase, Aside0x01TestHelper, AsideBaseTestHelper} from "./Aside0x01TestHelper.t.sol";
import {AsideBaseERC721Test} from "../helpers/AsideBase/tests/ERC721/AsideBase.ERC721.t.sol";

contract Aside0x01BaseERC721Test is Aside0x01TestHelper, AsideBaseERC721Test {
    function _mint() internal override(Aside0x01TestHelper, AsideBaseTestHelper) {
        super._mint();
    }

    function _mint(address to) internal override(Aside0x01TestHelper, AsideBaseTestHelper) {
        super._mint(to);
    }

    function test_metadata() public {
        assertEq(baseToken.name(), "Aside0x01");
        assertEq(baseToken.symbol(), "ASD0x01");
    }

    function test_mint() public mint {
        assertEq(token.sentimentOf(tokenId), sentiment);
    }

    function test_RevertWhen_mint_WithInvalidPayload() public mint {
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

    function test_RevertWhen_mint_WithInvalidTokenId() public mint {
        vm.expectRevert(abi.encodeWithSelector(AsideChainlink.InvalidTokenId.selector));
        vm.prank(minter);
        baseToken.mint(owner, 0, "060");
    }
}
