// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper} from "./Aside0x01Helper.sol";
import {IERC721Errors} from "../src/Aside01.sol";

contract OwnerOf is TestHelper {
    function test_ownerOf() public {
        assertEq(token.ownerOf(0), owners[0]);
        assertEq(token.ownerOf(1), owners[1]);
        assertEq(token.ownerOf(2), owners[2]);
    }

    function test_ownerOf_RevertWhenTokenIdDoesNotExist() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, 3));
        token.ownerOf(3);
    }
}
