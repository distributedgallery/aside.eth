// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideBase, Aside0x08TestHelper} from "./Aside0x08TestHelper.t.sol";

contract Aside0x08Constructor is Aside0x08TestHelper {
    function test_constructor_APTokensAreMinted() public {
        assertEq(token.ownerOf(94), 0x4D3DfD28AA35869D52C5cE077Aa36E3944b48d1C);
        assertEq(token.ownerOf(95), 0x4CD7d2004a323133330D5A62aD7C734fAfD35236);
        for (uint256 i = 96; i <= 99; i++) {
            assertEq(
                token.ownerOf(i),
                0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6
            );
        }
    }
}
