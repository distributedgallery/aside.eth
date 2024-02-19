// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {
    TestHelper,
    Aside0x01,
    IAsideErrors,
    IERC721Errors,
    IERC721Receiver,
    ERC721Recipient,
    RevertingERC721Recipient,
    WrongReturnDataERC721Recipient,
    NonERC721Recipient
} from "../Aside0x01Helper.t.sol";

/*
 * Safely transfers `tokenId` token from `from` to `to`.
 *
 * Requirements:
 *  - `from` cannot be the zero address.
 *  - `to` cannot be the zero address.
 *  - `tokenId` token must exist and be owned by `from`.
 *  - If the caller is not `from`, it must be approved to move this token by either approve or setApprovalForAll.
 *  - If to refers to a smart contract, it must implement IERC721Receiver.onERC721Received, which is called upon a safe transfer.
 * 
 * Emits a Transfer event.
 */
contract Transfer is TestHelper {
    function test_SafeTransferFromToEAO() public mint unlock {
        vm.prank(owner);
        token.setApprovalForAll(address(this), true);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, recipient, tokenId);

        token.safeTransferFrom(owner, recipient, tokenId);

        assertEq(token.getApproved(tokenId), address(0));
        assertEq(token.ownerOf(tokenId), recipient);
        assertEq(token.balanceOf(recipient), 1);
        assertEq(token.balanceOf(owner), 0);
    }

    // #region ERC721Recipient
    function test_SafeTransferFromToERC721Recipient() public mint unlock {
        ERC721Recipient to = new ERC721Recipient();

        vm.prank(owner);
        token.setApprovalForAll(address(this), true);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, address(to), tokenId);

        token.safeTransferFrom(owner, address(to), tokenId);

        assertEq(token.getApproved(tokenId), address(0));
        assertEq(token.ownerOf(tokenId), address(to));
        assertEq(token.balanceOf(address(to)), 1);
        assertEq(token.balanceOf(owner), 0);

        assertEq(to.operator(), address(this));
        assertEq(to.from(), owner);
        assertEq(to.id(), tokenId);
        assertEq(to.data(), "");
    }

    function test_SafeTransferFromToERC721RecipientWithData() public mint unlock {
        ERC721Recipient to = new ERC721Recipient();

        vm.prank(owner);
        token.setApprovalForAll(address(this), true);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, address(to), tokenId);

        token.safeTransferFrom(owner, address(to), tokenId, "this is a test");

        assertEq(token.getApproved(tokenId), address(0));
        assertEq(token.ownerOf(tokenId), address(to));
        assertEq(token.balanceOf(address(to)), 1);
        assertEq(token.balanceOf(owner), 0);

        assertEq(to.operator(), address(this));
        assertEq(to.from(), owner);
        assertEq(to.id(), tokenId);
        assertEq(to.data(), "this is a test");
    }
    // #endregion

    // #region NonERC721Recipient
    function test_RevertWhen_SafeTransferFromToNonERC721Recipient() public mint unlock {
        NonERC721Recipient to = new NonERC721Recipient();

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(to)));
        vm.prank(owner);
        token.safeTransferFrom(owner, address(to), tokenId);
    }

    function test_RevertWhen_SafeTransferFromToNonERC721RecipientWithData() public mint unlock {
        NonERC721Recipient to = new NonERC721Recipient();

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(to)));
        vm.prank(owner);
        token.safeTransferFrom(owner, address(to), tokenId, "this is a test");
    }
    // #endregion

    // #region RevertingERC721Recipient
    function test_RevertWhen_SafeTransferFromToRevertingERC721Recipient() public mint unlock {
        RevertingERC721Recipient to = new RevertingERC721Recipient();

        vm.expectRevert(abi.encodeWithSelector(IERC721Receiver.onERC721Received.selector));
        vm.prank(owner);
        token.safeTransferFrom(owner, address(to), tokenId);
    }

    function test_RevertWhen_SafeTransferFromToRevertingERC721RecipientWithData() public mint unlock {
        RevertingERC721Recipient to = new RevertingERC721Recipient();

        vm.expectRevert(abi.encodeWithSelector(IERC721Receiver.onERC721Received.selector));
        vm.prank(owner);
        token.safeTransferFrom(owner, address(to), tokenId, "this is a test");
    }
    // #endregion

    // #region ERC721RecipientWithWrongReturnData
    function test_RevertWhen_SafeTransferFromERC721RecipientWithWrongReturnData() public mint unlock {
        address to = address(new WrongReturnDataERC721Recipient());

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(to)));
        vm.prank(owner);
        token.safeTransferFrom(owner, to, tokenId);
    }

    function test_RevertWhen_SafeTransferFromERC721RecipientWithWrongReturnDataWithData() public mint unlock {
        address to = address(new WrongReturnDataERC721Recipient());

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(to)));
        vm.prank(owner);
        token.safeTransferFrom(owner, to, tokenId, "this is a test");
    }
    //#endregion

    function test_RevertWhen_SafeTransferFromNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        vm.prank(owner);
        token.safeTransferFrom(owner, recipient, tokenId);
    }

    function test_RevertWhen_SafeTransferFromUnauthorized() public mint unlock {
        vm.expectRevert(
            abi.encodeWithSelector(IERC721Errors.ERC721InsufficientApproval.selector, address(this), tokenId)
        );

        token.safeTransferFrom(owner, recipient, tokenId);
    }

    function test_RevertWhen_SafeTransferFromFromWrongOwner() public mint unlock {
        vm.expectRevert(
            abi.encodeWithSelector(IERC721Errors.ERC721IncorrectOwner.selector, address(0xDEAD), tokenId, owner)
        );
        vm.prank(owner);
        token.safeTransferFrom(address(0xDEAD), recipient, tokenId);
    }

    function test_RevertWhen_SafeTransferFromFromZero() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721IncorrectOwner.selector, address(0), tokenId, owner));
        vm.prank(owner);
        token.safeTransferFrom(address(0), recipient, tokenId);
    }

    function test_RevertWhen_SafeTransferFromToZero() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(0)));
        vm.prank(owner);
        token.safeTransferFrom(owner, address(0), tokenId);
    }

    function test_RevertWhen_SafeTransferFromLockedToken() public mint {
        vm.expectRevert(abi.encodeWithSelector(IAsideErrors.TokenLocked.selector, tokenId));
        vm.prank(owner);
        token.safeTransferFrom(owner, recipient, tokenId);
    }
}
