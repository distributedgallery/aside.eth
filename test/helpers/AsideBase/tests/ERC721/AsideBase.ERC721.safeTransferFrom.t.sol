// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideBase, AsideBaseTestHelper, IERC721Errors} from "../../AsideBaseTestHelper.t.sol";
import {
    IERC721Receiver,
    ERC721Recipient,
    NonERC721Recipient,
    RevertingERC721Recipient,
    WrongReturnDataERC721Recipient
} from "./ERC721TestHelper.t.sol";

abstract contract SafeTransferFrom is AsideBaseTestHelper {
    // #region EOA
    function test_safeTransferFrom_ToEOA_FromOwner() public mint unlock {
        vm.expectEmit(address(baseToken));
        emit Transfer(owner, recipient, tokenId);
        vm.prank(owner);
        baseToken.safeTransferFrom(owner, recipient, tokenId);

        assertEq(baseToken.ownerOf(tokenId), recipient);
        assertEq(baseToken.balanceOf(recipient), 1);
        assertEq(baseToken.balanceOf(owner), 0);
    }

    function test_safeTransferFrom_ToEOA_FromApproved() public mint unlock {
        vm.prank(owner);
        baseToken.approve(approved, tokenId);

        vm.expectEmit(address(baseToken));
        emit Transfer(owner, recipient, tokenId);
        vm.prank(approved);
        baseToken.safeTransferFrom(owner, recipient, tokenId);

        assertEq(baseToken.getApproved(tokenId), address(0));
        assertEq(baseToken.ownerOf(tokenId), recipient);
        assertEq(baseToken.balanceOf(recipient), 1);
        assertEq(baseToken.balanceOf(owner), 0);
    }

    function test_safeTransferFrom_ToEOA_FromOperator() public mint unlock {
        vm.prank(owner);
        baseToken.setApprovalForAll(operator, true);

        vm.expectEmit(address(baseToken));
        emit Transfer(owner, recipient, tokenId);
        vm.prank(operator);
        baseToken.safeTransferFrom(owner, recipient, tokenId);

        assertEq(baseToken.ownerOf(tokenId), recipient);
        assertEq(baseToken.balanceOf(recipient), 1);
        assertEq(baseToken.balanceOf(owner), 0);
    }

    function test_safeTransferFrom_ForLockedTokenOwnedByVerse() public {
        _mint(verse);
        vm.prank(verse);
        baseToken.safeTransferFrom(verse, recipient, tokenId);

        assertEq(baseToken.ownerOf(tokenId), recipient);
        assertEq(baseToken.balanceOf(recipient), 1);
        assertEq(baseToken.balanceOf(verse), 0);
    }
    // #endregion

    // #region ERC721Recipient
    function test_safeTransferFrom_ToERC721Recipient_WithoutData() public mint unlock {
        ERC721Recipient to = new ERC721Recipient();

        vm.prank(owner);
        baseToken.setApprovalForAll(address(this), true);

        vm.expectEmit(address(baseToken));
        emit Transfer(owner, address(to), tokenId);
        baseToken.safeTransferFrom(owner, address(to), tokenId);

        assertEq(baseToken.ownerOf(tokenId), address(to));
        assertEq(baseToken.balanceOf(address(to)), 1);
        assertEq(baseToken.balanceOf(owner), 0);

        assertEq(to.operator(), address(this));
        assertEq(to.from(), owner);
        assertEq(to.id(), tokenId);
        assertEq(to.data(), "");
    }

    function test_safeTransferFrom_ToERC721Recipient_WithData() public mint unlock {
        ERC721Recipient to = new ERC721Recipient();

        vm.prank(owner);
        baseToken.setApprovalForAll(address(this), true);

        vm.expectEmit(address(baseToken));
        emit Transfer(owner, address(to), tokenId);
        baseToken.safeTransferFrom(owner, address(to), tokenId, "thisisdata");

        assertEq(baseToken.ownerOf(tokenId), address(to));
        assertEq(baseToken.balanceOf(address(to)), 1);
        assertEq(baseToken.balanceOf(owner), 0);

        assertEq(to.operator(), address(this));
        assertEq(to.from(), owner);
        assertEq(to.id(), tokenId);
        assertEq(to.data(), "thisisdata");
    }
    // #endregion

    // #region NonERC721Recipient
    function test_RevertWhen_safeTransferFrom_ToNonERC721Recipient_WithoutData() public mint unlock {
        address to = address(new NonERC721Recipient());
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, to));
        vm.prank(owner);
        baseToken.safeTransferFrom(owner, to, tokenId);
    }

    function test_RevertWhen_safeTransferFrom_ToNonERC721Recipient_WithData() public mint unlock {
        address to = address(new NonERC721Recipient());
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, to));
        vm.prank(owner);
        baseToken.safeTransferFrom(owner, to, tokenId, "thisisdata");
    }
    // #endregion

    // #region RevertingERC721Recipient
    function test_RevertWhen_safeTransferFrom_ToRevertingERC721Recipient_WithoutData() public mint unlock {
        address to = address(new RevertingERC721Recipient());
        vm.expectRevert(abi.encodeWithSelector(IERC721Receiver.onERC721Received.selector));
        vm.prank(owner);
        baseToken.safeTransferFrom(owner, to, tokenId);
    }

    function test_RevertWhen_safeTransferFrom_ToRevertingERC721Recipient_WithData() public mint unlock {
        address to = address(new RevertingERC721Recipient());
        vm.expectRevert(abi.encodeWithSelector(IERC721Receiver.onERC721Received.selector));
        vm.prank(owner);
        baseToken.safeTransferFrom(owner, to, tokenId, "thisisdata");
    }
    // #endregion

    // #region ERC721RecipientWithWrongReturnData
    function test_RevertWhen_safeTransferFrom_ToWrongReturnDataERC721Recipient_WithoutData() public mint unlock {
        address to = address(new WrongReturnDataERC721Recipient());
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, to));
        vm.prank(owner);
        baseToken.safeTransferFrom(owner, to, tokenId);
    }

    function test_RevertWhen_safeTransferFrom_ToWrongReturnDataERC721Recipient_WithData() public mint unlock {
        address to = address(new WrongReturnDataERC721Recipient());
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, to));
        vm.prank(owner);
        baseToken.safeTransferFrom(owner, to, tokenId, "thisisdata");
    }
    // #endregion

    // #region generic errors
    function test_RevertWhen_safeTransferFrom_ForNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        baseToken.safeTransferFrom(address(0), recipient, tokenId);
    }

    function test_RevertWhen_safeTransferFrom_FromWrongOwner() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721IncorrectOwner.selector, address(0xDEAD), tokenId, owner));
        vm.prank(owner);
        baseToken.safeTransferFrom(address(0xDEAD), recipient, tokenId);
    }

    function test_RevertWhen_safeTransferFrom_FromZeroAddress() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721IncorrectOwner.selector, address(0), tokenId, owner));
        vm.prank(owner);
        baseToken.safeTransferFrom(address(0), recipient, tokenId);
    }

    function test_RevertWhen_safeTransferFrom_FromUnauthorized() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InsufficientApproval.selector, address(this), tokenId));
        baseToken.safeTransferFrom(owner, recipient, tokenId);
    }

    function test_RevertWhen_safeTransferFrom_ToZeroAddress() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(0)));
        vm.prank(owner);
        baseToken.safeTransferFrom(owner, address(0), tokenId);
    }

    function test_RevertWhen_safeTransferFrom_ForLockedToken() public mint {
        // owner
        vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenLocked.selector, tokenId));
        vm.prank(owner);
        baseToken.safeTransferFrom(owner, recipient, tokenId);

        // approved
        vm.prank(owner);
        baseToken.approve(approved, tokenId);
        vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenLocked.selector, tokenId));
        vm.prank(approved);
        baseToken.safeTransferFrom(owner, recipient, tokenId);

        // operator
        vm.prank(owner);
        baseToken.setApprovalForAll(operator, true);
        vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenLocked.selector, tokenId));
        vm.prank(operator);
        baseToken.safeTransferFrom(owner, recipient, tokenId);
    }
    // #endregion
}
