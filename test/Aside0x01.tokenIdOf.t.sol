// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TestHelper} from "./Aside0x01Helper.t.sol";

/**
 * Reviewed: OK.
 */
contract TokenIdOf is TestHelper {
    function test_tokenIdOf_WhenRequestExists() public mint {
        token.requestUnlock(tokenId);
        assertEq(token.tokenIdOf(router.REQUEST_ID()), tokenId);
    }

    function test_tokenIdOf_WhenRequestDoesNotExist() public {
        assertEq(token.tokenIdOf(router.REQUEST_ID()), 0);
    }
}
