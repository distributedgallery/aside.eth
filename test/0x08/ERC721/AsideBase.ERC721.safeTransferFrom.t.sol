// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x08, Aside0x08TestHelper, IERC721Errors} from "../Aside0x08TestHelper.t.sol";
import {IERC721Receiver, ERC721Recipient, NonERC721Recipient, RevertingERC721Recipient, WrongReturnDataERC721Recipient} from "./ERC721TestHelper.t.sol";

abstract contract SafeTransferFrom is Aside0x08TestHelper {
    // #region EOA
    function test_safeTransferFrom_ToEOA_FromOwner() public mint unlock {
        vm.expectEmit(address(token));
        emit Transfer(owner, recipient, tokenId);
        vm.prank(owner);
        token.safeTransferFrom(owner, recipient, tokenId);

        assertEq(token.ownerOf(tokenId), recipient);
        assertEq(token.balanceOf(recipient), 1);
        assertEq(token.balanceOf(owner), 0);
    }

    function test_safeTransferFrom_ToEOA_FromApproved() public mint unlock {
        vm.prank(owner);
        token.approve(approved, tokenId);

        vm.expectEmit(address(token));
        emit Transfer(owner, recipient, tokenId);
        vm.prank(approved);
        token.safeTransferFrom(owner, recipient, tokenId);

        assertEq(token.getApproved(tokenId), address(0));
        assertEq(token.ownerOf(tokenId), recipient);
        assertEq(token.balanceOf(recipient), 1);
        assertEq(token.balanceOf(owner), 0);
    }

    function test_safeTransferFrom_ToEOA_FromOperator() public mint unlock {
        vm.prank(owner);
        token.setApprovalForAll(operator, true);

        vm.expectEmit(address(token));
        emit Transfer(owner, recipient, tokenId);
        vm.prank(operator);
        token.safeTransferFrom(owner, recipient, tokenId);

        assertEq(token.ownerOf(tokenId), recipient);
        assertEq(token.balanceOf(recipient), 1);
        assertEq(token.balanceOf(owner), 0);
    }

    function test_safeTransferFrom_ForLockedTokenOwnedByDG() public {
        _mint(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6);
        uint256 balance = token.balanceOf(
            0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6
        );
        vm.prank(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6);
        token.safeTransferFrom(
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
        assertFalse(token.isUnlocked());

        vm.expectRevert(abi.encodeWithSelector(Aside0x08.Locked.selector));
        vm.prank(recipient);
        token.safeTransferFrom(
            0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6,
            recipient,
            tokenId
        );
    }

    // #endregion

    // #region ERC721Recipient
    function test_safeTransferFrom_ToERC721Recipient_WithoutData()
        public
        mint
        unlock
    {
        ERC721Recipient to = new ERC721Recipient();

        vm.prank(owner);
        token.setApprovalForAll(address(this), true);

        vm.expectEmit(address(token));
        emit Transfer(owner, address(to), tokenId);
        token.safeTransferFrom(owner, address(to), tokenId);

        assertEq(token.ownerOf(tokenId), address(to));
        assertEq(token.balanceOf(address(to)), 1);
        assertEq(token.balanceOf(owner), 0);

        assertEq(to.operator(), address(this));
        assertEq(to.from(), owner);
        assertEq(to.id(), tokenId);
        assertEq(to.data(), "");
    }

    function test_safeTransferFrom_ToERC721Recipient_WithData()
        public
        mint
        unlock
    {
        ERC721Recipient to = new ERC721Recipient();

        vm.prank(owner);
        token.setApprovalForAll(address(this), true);

        vm.expectEmit(address(token));
        emit Transfer(owner, address(to), tokenId);
        token.safeTransferFrom(owner, address(to), tokenId, "thisisdata");

        assertEq(token.ownerOf(tokenId), address(to));
        assertEq(token.balanceOf(address(to)), 1);
        assertEq(token.balanceOf(owner), 0);

        assertEq(to.operator(), address(this));
        assertEq(to.from(), owner);
        assertEq(to.id(), tokenId);
        assertEq(to.data(), "thisisdata");
    }

    // #endregion

    // #region NonERC721Recipient
    function test_RevertWhen_safeTransferFrom_ToNonERC721Recipient_WithoutData()
        public
        mint
        unlock
    {
        address to = address(new NonERC721Recipient());
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721InvalidReceiver.selector,
                to
            )
        );
        vm.prank(owner);
        token.safeTransferFrom(owner, to, tokenId);
    }

    function test_RevertWhen_safeTransferFrom_ToNonERC721Recipient_WithData()
        public
        mint
        unlock
    {
        address to = address(new NonERC721Recipient());
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721InvalidReceiver.selector,
                to
            )
        );
        vm.prank(owner);
        token.safeTransferFrom(owner, to, tokenId, "thisisdata");
    }

    // #endregion

    // #region RevertingERC721Recipient
    function test_RevertWhen_safeTransferFrom_ToRevertingERC721Recipient_WithoutData()
        public
        mint
        unlock
    {
        address to = address(new RevertingERC721Recipient());
        vm.expectRevert(
            abi.encodeWithSelector(IERC721Receiver.onERC721Received.selector)
        );
        vm.prank(owner);
        token.safeTransferFrom(owner, to, tokenId);
    }

    function test_RevertWhen_safeTransferFrom_ToRevertingERC721Recipient_WithData()
        public
        mint
        unlock
    {
        address to = address(new RevertingERC721Recipient());
        vm.expectRevert(
            abi.encodeWithSelector(IERC721Receiver.onERC721Received.selector)
        );
        vm.prank(owner);
        token.safeTransferFrom(owner, to, tokenId, "thisisdata");
    }

    // #endregion

    // #region ERC721RecipientWithWrongReturnData
    function test_RevertWhen_safeTransferFrom_ToWrongReturnDataERC721Recipient_WithoutData()
        public
        mint
        unlock
    {
        address to = address(new WrongReturnDataERC721Recipient());
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721InvalidReceiver.selector,
                to
            )
        );
        vm.prank(owner);
        token.safeTransferFrom(owner, to, tokenId);
    }

    function test_RevertWhen_safeTransferFrom_ToWrongReturnDataERC721Recipient_WithData()
        public
        mint
        unlock
    {
        address to = address(new WrongReturnDataERC721Recipient());
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721InvalidReceiver.selector,
                to
            )
        );
        vm.prank(owner);
        token.safeTransferFrom(owner, to, tokenId, "thisisdata");
    }

    // #endregion

    // #region generic errors
    function test_RevertWhen_safeTransferFrom_ForNonexistentToken() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721NonexistentToken.selector,
                tokenId
            )
        );
        token.safeTransferFrom(address(0), recipient, tokenId);
    }

    function test_RevertWhen_safeTransferFrom_FromWrongOwner()
        public
        mint
        unlock
    {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721IncorrectOwner.selector,
                address(0xDEAD),
                tokenId,
                owner
            )
        );
        vm.prank(owner);
        token.safeTransferFrom(address(0xDEAD), recipient, tokenId);
    }

    function test_RevertWhen_safeTransferFrom_FromZeroAddress()
        public
        mint
        unlock
    {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721IncorrectOwner.selector,
                address(0),
                tokenId,
                owner
            )
        );
        vm.prank(owner);
        token.safeTransferFrom(address(0), recipient, tokenId);
    }

    function test_RevertWhen_safeTransferFrom_FromUnauthorized()
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
        token.safeTransferFrom(owner, recipient, tokenId);
    }

    function test_RevertWhen_safeTransferFrom_ToZeroAddress()
        public
        mint
        unlock
    {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721InvalidReceiver.selector,
                address(0)
            )
        );
        vm.prank(owner);
        token.safeTransferFrom(owner, address(0), tokenId);
    }

    function test_RevertWhen_safeTransferFrom_ForLockedToken() public mint {
        // owner
        vm.expectRevert(abi.encodeWithSelector(Aside0x08.Locked.selector));
        vm.prank(owner);
        token.safeTransferFrom(owner, recipient, tokenId);

        // approved
        vm.prank(owner);
        token.approve(approved, tokenId);
        vm.expectRevert(abi.encodeWithSelector(Aside0x08.Locked.selector));
        vm.prank(approved);
        token.safeTransferFrom(owner, recipient, tokenId);

        // operator
        vm.prank(owner);
        token.setApprovalForAll(operator, true);
        vm.expectRevert(abi.encodeWithSelector(Aside0x08.Locked.selector));
        vm.prank(operator);
        token.safeTransferFrom(owner, recipient, tokenId);
    }
    // #endregion
}
