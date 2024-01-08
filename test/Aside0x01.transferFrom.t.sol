// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper} from "./Aside0x01Helper.sol";
import {Aside0x01, IERC721Errors} from "../src/Aside01.sol";

/*
 * Transfers tokenId token from from to to.
 *
 * Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721 or else they may be permanently lost. Usage of safeTransferFrom prevents loss, though the caller must understand this adds an external call which potentially creates a reentrancy vulnerability.
 * Requirements:
 *  - from cannot be the zero address.
 *  - to cannot be the zero address.
 *  - tokenId token must be owned by from.
 *  - If the caller is not from, it must be approved to move this token by either approve or setApprovalForAll.
 *  - Emits a Transfer event.
*/
contract Transfer is TestHelper {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function test_transferFrom() public {
        moveToUnlock();
        vm.prank(owners[0]);
        vm.expectEmit(true, true, true, true);
        emit Transfer(owners[0], owners[1], 0);

        token.transferFrom(owners[0], owners[1], 0);

        assertEq(token.ownerOf(0), owners[1]);
        assertEq(token.ownerOf(1), owners[1]);
        assertEq(token.ownerOf(2), owners[2]);
    }

    // function test_transferFrom_RevertWhenTokenIsStillLocked() public {
    //     vm.expectRevert(abi.encodeWithSelector(Aside0x01.TokenLocked.selector, 0));
    //     token.transferFrom(owners[0], owners[1], 0);
    // }

    function test_transferFrom_RevertWhenTokenIsStillLocked() public {
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

    function test_transferFrom_RevertFromZero() public {
        moveToUnlock();
        vm.prank(owners[0]);
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721IncorrectOwner.selector, address(0), 0, owners[0]));
        token.transferFrom(address(0), owners[1], 0);
    }

    function test_transferFrom_RevertToZero() public {
        moveToUnlock();
        vm.prank(owners[0]);
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(0)));

        token.transferFrom(owners[0], address(0), 0);
    }
}
