// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x01TestHelper, IERC721Errors} from "./Aside0x01TestHelper.t.sol";

contract SentimentOf is Aside0x01TestHelper {
    function test_sentimentOf() public mint {
        assertEq(token.sentimentOf(tokenId), sentiment);
    }

    function test_RevertWhen_sentimentOf_ForNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        token.sentimentOf(tokenId);
    }
}
