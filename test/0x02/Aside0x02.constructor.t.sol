// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x02TestHelper} from "./Aside0x02TestHelper.t.sol";

contract Aside0x02Constructor is Aside0x02TestHelper {
    function test_constructor_APTokensAreMinted() public {
        address DG = 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6;

        assertEq(token.ownerOf(120), 0x4D3DfD28AA35869D52C5cE077Aa36E3944b48d1C);
        assertEq(token.ownerOf(121), 0x4CD7d2004a323133330D5A62aD7C734fAfD35236);
        assertEq(token.ownerOf(122), DG);
        assertEq(token.ownerOf(123), DG);
        assertEq(token.ownerOf(124), DG);
        assertEq(token.ownerOf(125), 0x4D3DfD28AA35869D52C5cE077Aa36E3944b48d1C);
        assertEq(token.ownerOf(126), 0x4CD7d2004a323133330D5A62aD7C734fAfD35236);
        assertEq(token.ownerOf(127), DG);
        assertEq(token.ownerOf(128), DG);
        assertEq(token.ownerOf(129), DG);
    }

    function test_constructor_SomeAPTokensAreLocked() public {
        assertFalse(token.isUnlocked(120));
        assertFalse(token.isUnlocked(121));
        assertFalse(token.isUnlocked(125));
        assertFalse(token.isUnlocked(126));
    }

    function test_constructor_MostAPTokensAreUnlocked() public {
        assertTrue(token.isUnlocked(122));
        assertTrue(token.isUnlocked(123));
        assertTrue(token.isUnlocked(124));
        assertTrue(token.isUnlocked(127));
        assertTrue(token.isUnlocked(128));
        assertTrue(token.isUnlocked(129));
    }
}
