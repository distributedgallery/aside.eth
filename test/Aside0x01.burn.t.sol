// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper, IERC721Errors} from "./Aside0x01Helper.sol";

/**
 * Burns `tokenId`. The approval is cleared when the token is burned.
 *
 * Requirements:
 *  - The caller must own `tokenId` or be an approved operator.
 *  - tokenId must exist.
 *
 * Emits a Transfer event.
 */
contract Burn is TestHelper {
    function test_BurnFromOwner() public mint unlock {
        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, address(0), tokenId);

        vm.prank(owner);
        token.burn(tokenId);

        assertEq(token.balanceOf(owner), 0);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        token.ownerOf(tokenId);
    }

    function test_BurnFromApprovedOperator() public mint unlock {
        vm.prank(owner);
        token.approve(operator, tokenId);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, address(0), tokenId);

        vm.prank(operator);
        token.burn(tokenId);

        assertEq(token.balanceOf(owner), 0);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        token.getApproved(tokenId);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        token.ownerOf(tokenId);
    }

    function test_BurnFromApprovedOperatorForAll() public mint unlock {
        vm.prank(owner);
        token.setApprovalForAll(operator, true);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, address(0), tokenId);

        vm.prank(operator);
        token.burn(tokenId);

        assertEq(token.balanceOf(owner), 0);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        token.ownerOf(tokenId);
    }
}