// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x08TestHelper, IERC721Errors} from "../Aside0x08TestHelper.t.sol";

abstract contract Approve is Aside0x08TestHelper {
    function test_approve_FromOwner() public mint {
        vm.expectEmit(address(token));
        emit Approval(owner, approved, tokenId);
        vm.prank(owner);
        token.approve(approved, tokenId);

        assertEq(token.getApproved(tokenId), approved);
    }

    function test_approve_FromOperator() public mint {
        vm.prank(owner);
        token.setApprovalForAll(operator, true);

        vm.expectEmit(address(token));
        emit Approval(owner, approved, tokenId);
        vm.prank(operator);
        token.approve(approved, tokenId);

        assertEq(token.getApproved(tokenId), approved);
    }

    function test_RevertWhen_approve_FromUnauthorized() public mint {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721InvalidApprover.selector,
                address(this)
            )
        );
        token.approve(approved, tokenId);
    }

    function test_RevertWhen_approve_ForNonexistentToken() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721NonexistentToken.selector,
                tokenId
            )
        );
        token.approve(approved, tokenId);
    }
}
