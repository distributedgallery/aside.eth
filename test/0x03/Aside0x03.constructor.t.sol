// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x03TestHelper} from "./Aside0x03TestHelper.t.sol";

contract Aside0x03Constructor is Aside0x03TestHelper {
    function test_constructor_FeedIsRegistered() public {
        assertEq(address(token.feed()), address(feed));
    }

    function test_constructor_APsAreMinted() public {
        assertEq(token.ownerOf(200), 0x4D3DfD28AA35869D52C5cE077Aa36E3944b48d1C);
        assertEq(token.ownerOf(201), 0x4CD7d2004a323133330D5A62aD7C734fAfD35236);
        assertEq(token.ownerOf(202), 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6);
        assertEq(token.ownerOf(203), 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6);
        assertEq(token.ownerOf(204), 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6);
        assertEq(token.ownerOf(205), 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6);
        assertEq(token.ownerOf(206), 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6);
        assertEq(token.ownerOf(207), 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6);
        assertEq(token.ownerOf(208), 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6);
        assertEq(token.ownerOf(209), 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6);
    }

    function test_constructor_SomeAPsAreLocked() public {
        assertFalse(token.isUnlocked(200));
        assertFalse(token.isUnlocked(201));
    }

    function test_constructor_MostAPsAreUnlocked() public {
        assertTrue(token.isUnlocked(202));
        assertTrue(token.isUnlocked(203));
        assertTrue(token.isUnlocked(204));
        assertTrue(token.isUnlocked(205));
        assertTrue(token.isUnlocked(206));
        assertTrue(token.isUnlocked(207));
        assertTrue(token.isUnlocked(208));
        assertTrue(token.isUnlocked(209));
    }
}
