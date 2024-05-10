// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideBaseTestHelper, IERC721Errors} from "../../AsideBaseTestHelper.t.sol";

abstract contract SetApprovalForAll is AsideBaseTestHelper {
    function test_setApprovalForAll_Approve() public mint unlock {
        vm.expectEmit(true, true, true, true);
        emit ApprovalForAll(owner, operator, true);
        vm.prank(owner);
        baseToken.setApprovalForAll(operator, true);
        assertTrue(baseToken.isApprovedForAll(owner, operator));

        vm.prank(operator);
        baseToken.safeTransferFrom(owner, recipient, tokenId);
        assertEq(baseToken.ownerOf(tokenId), recipient);
    }

    function test_setApprovalForAll_Unapprove() public mint unlock {
        vm.prank(owner);
        baseToken.setApprovalForAll(operator, true);
        assertTrue(baseToken.isApprovedForAll(owner, operator));

        vm.expectEmit(true, true, true, true);
        emit ApprovalForAll(owner, operator, false);
        vm.prank(owner);
        baseToken.setApprovalForAll(operator, false);
        assertFalse(baseToken.isApprovedForAll(owner, operator));

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InsufficientApproval.selector, operator, tokenId));
        vm.prank(operator);
        baseToken.safeTransferFrom(owner, recipient, tokenId);
    }

    function test_RevertWhen_setApprovalForAll_ToZeroAddress() public mint {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidOperator.selector, address(0)));
        vm.prank(owner);
        baseToken.setApprovalForAll(address(0), true);
    }
}
