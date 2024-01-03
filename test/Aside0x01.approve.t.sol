// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper} from "./Aside0x01Helper.sol";
import {IERC721Errors} from "../src/Aside01.sol";

contract Approve is TestHelper {
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    function test_approve_FromOwner() public {
        vm.expectEmit(true, true, true, true);
        emit Approval(owners[0], owners[1], 0);
        vm.prank(owners[0]);
        token.approve(owners[1], 0);

        assertEq(token.getApproved(0), owners[1]);
    }

    function test_approve_FromApprovedOperatorForAll() public {
        vm.prank(owners[0]);
        token.setApprovalForAll(owners[1], true);

        vm.expectEmit(true, true, true, true);
        emit Approval(owners[0], owners[2], 0);
        vm.prank(owners[1]);
        token.approve(owners[2], 0);

        assertEq(token.getApproved(0), owners[2]);
    }

    function test_approve_RevertWhenFromNeitherOwnerNorApprovedOperatorForAll() public {
        vm.prank(owners[1]);
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidApprover.selector, owners[1]));
        token.approve(owners[2], 0);
    }
}
