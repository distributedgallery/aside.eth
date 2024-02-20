// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper, IERC721Errors} from "./Aside0x01Helper.t.sol";

/**
 * Reviewed: OK.
 */
contract SentimentOf is TestHelper {
    function test_sentimentOf() public mint {
        assertEq(token.sentimentOf(tokenId), sentiment);
    }

    function test_RevertWhen_sentimentOfNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        token.sentimentOf(tokenId);
    }
}
