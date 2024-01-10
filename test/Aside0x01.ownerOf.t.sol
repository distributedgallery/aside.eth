// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper, IERC721Errors} from "./Aside0x01Helper.sol";

/**
 * Returns the owner of the tokenId token.
 * Requirements:
 *  - `tokenId` must exist.
 */
contract OwnerOf is TestHelper {
    function test_OwnerOf() public mint {
        assertEq(token.ownerOf(tokenId), owner);
    }

    function test_RevertWhen_OwnerOfNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        token.ownerOf(tokenId);
    }
}
