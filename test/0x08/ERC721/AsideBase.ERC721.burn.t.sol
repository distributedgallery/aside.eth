// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x08, Aside0x08TestHelper, IERC721Errors} from "../Aside0x08TestHelper.t.sol";

abstract contract Burn is Aside0x08TestHelper {
    function test_burn_FromOwner() public mint unlock {
        vm.expectEmit(address(token));
        emit Transfer(owner, address(0), tokenId);
        vm.prank(owner);
        token.burn(tokenId);

        assertEq(token.balanceOf(owner), 0);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721NonexistentToken.selector,
                tokenId
            )
        );
        token.ownerOf(tokenId);
    }

    function test_burn_FromApproved() public mint unlock {
        vm.prank(owner);
        token.approve(approved, tokenId);

        vm.expectEmit(address(token));
        emit Transfer(owner, address(0), tokenId);
        vm.prank(approved);
        token.burn(tokenId);

        assertEq(token.balanceOf(owner), 0);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721NonexistentToken.selector,
                tokenId
            )
        );
        token.getApproved(tokenId);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721NonexistentToken.selector,
                tokenId
            )
        );
        token.ownerOf(tokenId);
    }

    function test_burn_FromOperator() public mint unlock {
        vm.prank(owner);
        token.setApprovalForAll(operator, true);

        vm.expectEmit(address(token));
        emit Transfer(owner, address(0), tokenId);
        vm.prank(operator);
        token.burn(tokenId);

        assertEq(token.balanceOf(owner), 0);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721NonexistentToken.selector,
                tokenId
            )
        );
        token.ownerOf(tokenId);
    }

    function test_RevertWhen_burn_FromUnauthorized() public mint unlock {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721InsufficientApproval.selector,
                address(this),
                tokenId
            )
        );
        token.burn(tokenId);
    }

    function test_RevertWhen_burn_ForNonexistentToken() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721NonexistentToken.selector,
                tokenId
            )
        );
        vm.prank(owner);
        token.burn(tokenId);
    }

    function test_RevertWhen_burn_ForLockedToken() public mint {
        vm.expectRevert(
            abi.encodeWithSelector(Aside0x08.Locked.selector, tokenId)
        );
        vm.prank(owner);
        token.burn(tokenId);
    }
}
