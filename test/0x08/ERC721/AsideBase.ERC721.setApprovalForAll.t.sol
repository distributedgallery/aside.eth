// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x08TestHelper, IERC721Errors} from "../Aside0x08TestHelper.t.sol";

abstract contract SetApprovalForAll is Aside0x08TestHelper {
    function test_setApprovalForAll_Approve() public mint unlock {
        vm.expectEmit(address(token));
        emit ApprovalForAll(owner, operator, true);
        vm.prank(owner);
        token.setApprovalForAll(operator, true);
        assertTrue(token.isApprovedForAll(owner, operator));

        vm.prank(operator);
        token.safeTransferFrom(owner, recipient, tokenId);
        assertEq(token.ownerOf(tokenId), recipient);
    }

    function test_setApprovalForAll_Unapprove() public mint unlock {
        vm.prank(owner);
        token.setApprovalForAll(operator, true);
        assertTrue(token.isApprovedForAll(owner, operator));

        vm.expectEmit(address(token));
        emit ApprovalForAll(owner, operator, false);
        vm.prank(owner);
        token.setApprovalForAll(operator, false);
        assertFalse(token.isApprovedForAll(owner, operator));

        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721InsufficientApproval.selector,
                operator,
                tokenId
            )
        );
        vm.prank(operator);
        token.safeTransferFrom(owner, recipient, tokenId);
    }

    function test_RevertWhen_setApprovalForAll_ToZeroAddress() public mint {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721InvalidOperator.selector,
                address(0)
            )
        );
        vm.prank(owner);
        token.setApprovalForAll(address(0), true);
    }
}
