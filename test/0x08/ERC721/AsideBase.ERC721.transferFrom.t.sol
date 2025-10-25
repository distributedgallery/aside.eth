// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x08, Aside0x08TestHelper, IERC721Errors} from "../Aside0x08TestHelper.t.sol";

abstract contract TransferFrom is Aside0x08TestHelper {
    function test_transferFrom_FromOwner() public mint unlock {
        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, recipient, tokenId);
        vm.prank(owner);
        token.transferFrom(owner, recipient, tokenId);

        assertEq(token.ownerOf(tokenId), recipient);
        assertEq(token.balanceOf(recipient), 1);
        assertEq(token.balanceOf(owner), 0);
    }

    function test_transferFrom_FromApproved() public mint unlock {
        vm.prank(owner);
        token.approve(approved, tokenId);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, recipient, tokenId);
        vm.prank(approved);
        token.transferFrom(owner, recipient, tokenId);

        assertEq(token.getApproved(tokenId), address(0));
        assertEq(token.ownerOf(tokenId), recipient);
        assertEq(token.balanceOf(recipient), 1);
        assertEq(token.balanceOf(owner), 0);
    }

    function test_transferFrom_FromOperator() public mint unlock {
        vm.prank(owner);
        token.setApprovalForAll(operator, true);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, recipient, tokenId);
        vm.prank(operator);
        token.transferFrom(owner, recipient, tokenId);

        assertEq(token.ownerOf(tokenId), recipient);
        assertEq(token.balanceOf(recipient), 1);
        assertEq(token.balanceOf(owner), 0);
    }

    function test_transferFrom_ForLockedTokenOwnedByDG() public {
        _mint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6);
        uint256 balance = token.balanceOf(
            0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6
        );
        vm.prank(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6);
        token.transferFrom(
            0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6,
            recipient,
            tokenId
        );
        assertEq(token.ownerOf(tokenId), recipient);
        assertEq(token.balanceOf(recipient), 1);
        assertEq(
            token.balanceOf(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6),
            balance - 1
        );
        vm.expectRevert(abi.encodeWithSelector(Aside0x08.Locked.selector));
        vm.prank(recipient);
        token.safeTransferFrom(
            0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6,
            recipient,
            tokenId
        );
    }

    function test_RevertWhen_transferFrom_ForNonexistentToken() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721NonexistentToken.selector,
                tokenId
            )
        );
        token.transferFrom(address(0), recipient, tokenId);
    }

    function test_RevertWhen_transferFrom_FromWrongOwner() public mint unlock {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721IncorrectOwner.selector,
                address(0xDEAD),
                tokenId,
                owner
            )
        );
        vm.prank(owner);
        token.transferFrom(address(0xDEAD), recipient, tokenId);
    }

    function test_RevertWhen_transferFrom_FromZeroAddress() public mint unlock {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721IncorrectOwner.selector,
                address(0),
                tokenId,
                owner
            )
        );
        vm.prank(owner);
        token.transferFrom(address(0), recipient, tokenId);
    }

    function test_RevertWhen_transferFrom_FromUnauthorized()
        public
        mint
        unlock
    {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721InsufficientApproval.selector,
                address(this),
                tokenId
            )
        );
        token.transferFrom(recipient, recipient, tokenId);
    }

    function test_RevertWhen_transferFrom_ToZeroAddress() public mint unlock {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721InvalidReceiver.selector,
                address(0)
            )
        );
        vm.prank(owner);
        token.transferFrom(owner, address(0), tokenId);
    }

    function test_RevertWhen_transferFrom_ForLockedToken() public mint {
        // owner
        vm.expectRevert(abi.encodeWithSelector(Aside0x08.Locked.selector));
        vm.prank(owner);
        token.transferFrom(owner, recipient, tokenId);

        // approved
        vm.prank(owner);
        token.approve(approved, tokenId);
        vm.expectRevert(abi.encodeWithSelector(Aside0x08.Locked.selector));
        vm.prank(approved);
        token.transferFrom(owner, recipient, tokenId);

        // operator
        vm.prank(owner);
        token.setApprovalForAll(operator, true);
        vm.expectRevert(abi.encodeWithSelector(Aside0x08.Locked.selector));
        vm.prank(operator);
        token.transferFrom(owner, recipient, tokenId);
    }
}
