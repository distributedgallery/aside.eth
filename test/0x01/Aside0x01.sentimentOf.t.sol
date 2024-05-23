// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x01TestHelper, IERC721Errors} from "./Aside0x01TestHelper.t.sol";

contract SentimentOf is Aside0x01TestHelper {
    function test_sentimentOf() public mint {
        assertEq(token.sentimentOf(tokenId), sentiment);

        vm.startPrank(minter);
        token.mint(owner, 3);
        token.mint(owner, 15);
        token.mint(owner, 20);
        token.mint(owner, 79);
        token.mint(owner, 99);
        // token.mint(owner, 100);
        // token.mint(owner, 101);
        // token.mint(owner, 104);
        vm.stopPrank();

        assertEq(token.sentimentOf(3), 0);
        assertEq(token.sentimentOf(15), 10);
        assertEq(token.sentimentOf(20), 20);
        assertEq(token.sentimentOf(79), 70);
        assertEq(token.sentimentOf(99), 90);
        // assertEq(token.sentimentOf(100), 70);
        // assertEq(token.sentimentOf(101), 60);
        // assertEq(token.sentimentOf(104), 0);
    }

    function test_RevertWhen_sentimentOf_ForNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        token.sentimentOf(tokenId);
    }

    function test_RevertWhen_sentimentOf_ForBurntToken() public mint unlock {
        vm.prank(owner);
        token.burn(tokenId);
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        token.sentimentOf(tokenId);
    }
}
