// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper, IERC721Errors} from "./Aside0x01Helper.t.sol";

/**
 * Returns the Uniform Resource Identifier (URI) for `tokenId` token.
 */
contract TokenURI is TestHelper {
    function test_TokenURI() public mint {
        assertEq(token.tokenURI(tokenId), tokenURI);
    }

    function test_RevertWhen_TokenURIOfNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, 9999));
        token.tokenURI(9999);
    }
}
