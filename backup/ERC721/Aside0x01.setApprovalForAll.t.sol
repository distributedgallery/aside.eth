// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper, IERC721Errors} from "../Aside0x01Helper.t.sol";

/*
 * Approve or remove operator as an operator for the caller. Operators can call `transferFrom` or `safeTransferFrom` for any token owned by the caller.
 *
 * Requirements:
 *  - The operator cannot be the address zero.
 *
 * Emits an ApprovalForAll event.
 */
contract SetApprovalForAll is TestHelper {
    function test_SetApprovalForAll() public mint {
        address operator2 = address(0xBEEF);

        vm.expectEmit(true, true, true, true);
        emit ApprovalForAll(owner, operator, true);

        vm.prank(owner);
        token.setApprovalForAll(operator, true);

        vm.expectEmit(true, true, true, true);
        emit ApprovalForAll(owner, operator2, true);

        vm.prank(owner);
        token.setApprovalForAll(operator2, true);

        assertTrue(token.isApprovedForAll(owner, operator));
        assertTrue(token.isApprovedForAll(owner, operator2));

        vm.expectEmit(true, true, true, true);
        emit ApprovalForAll(owner, operator, false);

        vm.prank(owner);
        token.setApprovalForAll(operator, false);

        assertFalse(token.isApprovedForAll(owner, operator));
        assertTrue(token.isApprovedForAll(owner, operator2));
    }

    function test_RevertWhen_SetApprovalForAllToZeroAddress() public mint {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidOperator.selector, address(0)));
        vm.prank(owner);
        token.setApprovalForAll(address(0), true);
    }
}
