// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideBase, AsideBaseTestHelper, IERC721Errors} from "../../AsideBaseTestHelper.t.sol";

abstract contract TransferFrom is AsideBaseTestHelper {
    function test_transferFrom_AfterTimelock() public mint {
        vm.warp(baseToken.TIMELOCK_DEADLINE());

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, recipient, tokenId);
        vm.prank(owner);
        baseToken.transferFrom(owner, recipient, tokenId);

        assertEq(baseToken.ownerOf(tokenId), recipient);
        assertEq(baseToken.balanceOf(recipient), 1);
        assertEq(baseToken.balanceOf(owner), 0);
    }

    function test_transferFrom_AfterEmergencyUnlock() public mint {
        vm.prank(admin);
        baseToken.eUnlock();

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, recipient, tokenId);
        vm.prank(owner);
        baseToken.transferFrom(owner, recipient, tokenId);

        assertEq(baseToken.ownerOf(tokenId), recipient);
        assertEq(baseToken.balanceOf(recipient), 1);
        assertEq(baseToken.balanceOf(owner), 0);
    }

    function test_transferFrom_FromOwner() public mint unlock {
        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, recipient, tokenId);
        vm.prank(owner);
        baseToken.transferFrom(owner, recipient, tokenId);

        assertEq(baseToken.ownerOf(tokenId), recipient);
        assertEq(baseToken.balanceOf(recipient), 1);
        assertEq(baseToken.balanceOf(owner), 0);
    }

    function test_transferFrom_FromApproved() public mint unlock {
        vm.prank(owner);
        baseToken.approve(approved, tokenId);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, recipient, tokenId);
        vm.prank(approved);
        baseToken.transferFrom(owner, recipient, tokenId);

        assertEq(baseToken.getApproved(tokenId), address(0));
        assertEq(baseToken.ownerOf(tokenId), recipient);
        assertEq(baseToken.balanceOf(recipient), 1);
        assertEq(baseToken.balanceOf(owner), 0);
    }

    function test_transferFrom_FromOperator() public mint unlock {
        vm.prank(owner);
        baseToken.setApprovalForAll(operator, true);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, recipient, tokenId);
        vm.prank(operator);
        baseToken.transferFrom(owner, recipient, tokenId);

        assertEq(baseToken.ownerOf(tokenId), recipient);
        assertEq(baseToken.balanceOf(recipient), 1);
        assertEq(baseToken.balanceOf(owner), 0);
    }

    function test_transferFrom_ForLockedTokenOwnedByVerse() public {
        _mint(verse);
        vm.prank(verse);
        baseToken.transferFrom(verse, recipient, tokenId);

        assertEq(baseToken.ownerOf(tokenId), recipient);
        assertEq(baseToken.balanceOf(recipient), 1);
        assertEq(baseToken.balanceOf(verse), 0);
        assertFalse(baseToken.isUnlocked(tokenId));

        vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenLocked.selector, tokenId));
        vm.prank(recipient);
        baseToken.safeTransferFrom(verse, recipient, tokenId);
    }

    function test_transferFrom_ForLockedTokenOwnedByDG() public {
        _mint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6);
        vm.prank(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6);
        baseToken.transferFrom(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, recipient, tokenId);

        assertEq(baseToken.ownerOf(tokenId), recipient);
        assertEq(baseToken.balanceOf(recipient), 1);
        // assertEq(baseToken.balanceOf(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6), 0);
        assertFalse(baseToken.isUnlocked(tokenId));

        vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenLocked.selector, tokenId));
        vm.prank(recipient);
        baseToken.safeTransferFrom(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, recipient, tokenId);
    }

    function test_RevertWhen_transferFrom_ForNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        baseToken.transferFrom(address(0), recipient, tokenId);
    }

    function test_RevertWhen_transferFrom_FromWrongOwner() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721IncorrectOwner.selector, address(0xDEAD), tokenId, owner));
        vm.prank(owner);
        baseToken.transferFrom(address(0xDEAD), recipient, tokenId);
    }

    function test_RevertWhen_transferFrom_FromZeroAddress() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721IncorrectOwner.selector, address(0), tokenId, owner));
        vm.prank(owner);
        baseToken.transferFrom(address(0), recipient, tokenId);
    }

    function test_RevertWhen_transferFrom_FromUnauthorized() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InsufficientApproval.selector, address(this), tokenId));
        baseToken.transferFrom(recipient, recipient, tokenId);
    }

    function test_RevertWhen_transferFrom_ToZeroAddress() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(0)));
        vm.prank(owner);
        baseToken.transferFrom(owner, address(0), tokenId);
    }

    function test_RevertWhen_transferFrom_ForLockedToken() public mint {
        // owner
        vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenLocked.selector, tokenId));
        vm.prank(owner);
        baseToken.transferFrom(owner, recipient, tokenId);

        // approved
        vm.prank(owner);
        baseToken.approve(approved, tokenId);
        vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenLocked.selector, tokenId));
        vm.prank(approved);
        baseToken.transferFrom(owner, recipient, tokenId);

        // operator
        vm.prank(owner);
        baseToken.setApprovalForAll(operator, true);
        vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenLocked.selector, tokenId));
        vm.prank(operator);
        baseToken.transferFrom(owner, recipient, tokenId);
    }
}
