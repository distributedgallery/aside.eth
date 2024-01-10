// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper} from "./Aside0x01Helper.sol";
import {Aside0x01, IERC721Errors} from "../src/Aside01.sol";

/*
 * Transfers `tokenId` token from `from` to `to`. Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721 or else they may be permanently lost. Usage of safeTransferFrom prevents loss, though the caller must understand this adds an external call which potentially creates a reentrancy vulnerability.
 * 
 * Requirements:
 *  - `from` cannot be the zero address.
 *  - `to` cannot be the zero address.
 *  - `tokenId` token must be owned by `from`.
 *  - If the caller is not from, it must be approved to move this token by either approve or setApprovalForAll.
 * 
 * - Emits a Transfer event.
 */
contract Transfer is TestHelper {
    function test_TransferFromFromOwner() public mint unlock {
        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, recipient, tokenId);

        vm.prank(owner);
        token.transferFrom(owner, recipient, tokenId);

        assertEq(token.ownerOf(tokenId), recipient);
        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(recipient), 1);
    }

    function test_TransferFromFromApprovedAddress() public mint unlock {
        vm.prank(owner);
        token.approve(approved, tokenId);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, recipient, tokenId);

        vm.prank(approved);
        token.transferFrom(owner, recipient, tokenId);

        assertEq(token.ownerOf(tokenId), recipient);
        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(recipient), 1);
        assertEq(token.getApproved(tokenId), address(0));
    }

    function test_TransferFromFromAuthorizedOperator() public mint unlock {
        vm.prank(owner);
        token.setApprovalForAll(operator, true);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, recipient, tokenId);

        vm.prank(operator);
        token.transferFrom(owner, recipient, tokenId);

        assertEq(token.ownerOf(tokenId), recipient);
        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(recipient), 1);
        assertTrue(token.isApprovedForAll(owner, operator));
    }

    // function test_transferFrom_RevertWhenTokenIsStillLocked() public {
    //     vm.expectRevert(abi.encodeWithSelector(Aside0x01.TokenLocked.selector, 0));
    //     token.transferFrom(owners[0], owners[1], 0);
    // }

    function test_RevertWhen_TransferFromTokenLocked() public mint {
        // revert when caller is owner
        vm.expectRevert(abi.encodeWithSelector(Aside0x01.TokenLocked.selector, 0));
        token.transferFrom(owners[0], owners[1], 0);
        // revert when caller is approved
        vm.prank(owners[0]);
        token.approve(owners[1], 0);
        vm.prank(owners[1]);
        vm.expectRevert(abi.encodeWithSelector(Aside0x01.TokenLocked.selector, 0));
        token.transferFrom(owners[0], owners[1], 0);
        // revert when caller is approved for all
        vm.prank(owners[0]);
        token.setApprovalForAll(owners[0], true);
        vm.expectRevert(abi.encodeWithSelector(Aside0x01.TokenLocked.selector, 0));
        token.transferFrom(owners[0], owners[1], 0);
    }

    function test_RevertWhen_TransferFromFromNeitherOwnerNorApprovedAddressNorAuthorizedOperator() public mint unlock {
        vm.expectRevert(
            abi.encodeWithSelector(IERC721Errors.ERC721InsufficientApproval.selector, address(this), tokenId)
        );
        token.transferFrom(recipient, recipient, tokenId);
    }

    function test_RevertWhen_TransferFromFromWrongOwner() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721IncorrectOwner.selector, recipient, tokenId, owner));
        vm.prank(owner);
        token.transferFrom(recipient, recipient, tokenId);
    }

    function test_RevertWhen_TransferFromFromZero() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721IncorrectOwner.selector, address(0), tokenId, owner));
        vm.prank(owner);
        token.transferFrom(address(0), recipient, tokenId);
    }

    function test_RevertWhen_TransferFromToZero() public mint unlock {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(0)));
        vm.prank(owner);
        token.transferFrom(owner, address(0), tokenId);
    }

    function test_RevertWhen_TransferFromNonExistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        vm.prank(owner);
        token.transferFrom(owner, recipient, tokenId);
    }
}
