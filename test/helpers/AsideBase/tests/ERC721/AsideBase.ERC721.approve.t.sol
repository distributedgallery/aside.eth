// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideBaseTestHelper, IERC721Errors} from "../../AsideBaseTestHelper.t.sol";

abstract contract Approve is AsideBaseTestHelper {
    function test_approve_FromOwner() public mint {
        vm.expectEmit(true, true, true, true);
        emit Approval(owner, approved, tokenId);
        vm.prank(owner);
        baseToken.approve(approved, tokenId);

        assertEq(baseToken.getApproved(tokenId), approved);
    }

    function test_approve_FromOperator() public mint {
        vm.prank(owner);
        baseToken.setApprovalForAll(operator, true);

        vm.expectEmit(true, true, true, true);
        emit Approval(owner, approved, tokenId);
        vm.prank(operator);
        baseToken.approve(approved, tokenId);

        assertEq(baseToken.getApproved(tokenId), approved);
    }

    function test_RevertWhen_approve_FromUnauthorized() public mint {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidApprover.selector, address(this)));
        baseToken.approve(approved, tokenId);
    }

    function test_RevertWhen_approve_ForNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        baseToken.approve(approved, tokenId);
    }
}
