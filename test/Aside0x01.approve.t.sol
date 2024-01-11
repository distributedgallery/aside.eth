// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper, IERC721Errors} from "./Aside0x01Helper.sol";

/*
 * Gives permission to `to` to transfer `tokenId` token to another account. The approval is cleared when the token is transferred.
 * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
 *
 * Requirements:
 *  - The caller must own the token or be an approved operator.
 *  - `tokenId` must exist.
 *
 * - Emits an Approval event.
 */
contract Approve is TestHelper {
    function test_ApproveFromOwner() public mint {
        vm.expectEmit(true, true, true, true);
        emit Approval(owner, approved, tokenId);

        vm.prank(owner);
        token.approve(approved, tokenId);

        assertEq(token.getApproved(tokenId), approved);
    }

    function test_ApproveFromOperator() public mint {
        vm.prank(owner);
        token.setApprovalForAll(operator, true);

        vm.expectEmit(true, true, true, true);
        emit Approval(owner, approved, tokenId);

        vm.prank(operator);
        token.approve(approved, tokenId);

        assertEq(token.getApproved(tokenId), approved);
    }

    function test_RevertWhen_ApproveFromUnauthorized() public mint {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidApprover.selector, address(this)));
        token.approve(approved, tokenId);
    }

    function test_RevertWhen_ApproveNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        token.approve(approved, tokenId);
    }
}
