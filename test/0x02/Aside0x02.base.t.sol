// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Aside0x02, AsideBase, Aside0x02TestHelper} from "./Aside0x02TestHelper.t.sol";
import {AsideBaseTest} from "../helpers/AsideBase/tests/AsideBase.t.sol";

contract Aside0x02BaseTest is Aside0x02TestHelper, AsideBaseTest {
    // #region helpers
    function tRangeUnlocked(uint256 limit) public {
        for (uint256 i = 0; i < limit; i++) {
            assertTrue(baseToken.isUnlocked(i));
        }
        for (uint256 i = limit < 5 ? 0 : limit - 5; i < limit; i++) {
            vm.prank(owner);
            vm.expectEmit(address(baseToken));
            emit Transfer(owner, recipient, i);
            baseToken.transferFrom(owner, recipient, i);
            assertEq(baseToken.ownerOf(i), recipient);
        }
        for (uint256 i = limit; i < 120; i++) {
            assertFalse(baseToken.isUnlocked(i));
            vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenLocked.selector, i));
            vm.prank(owner);
            baseToken.transferFrom(owner, recipient, i);
        }
    }
    // #endregion

    // #region NB_OF_TOKENS
    function test_NB_OF_TOKENS() public {
        assertEq(baseToken.NB_OF_TOKENS(), 130);
    }
    // #endregion

    // #region unlock
    function test_unlock() public {
        vm.startPrank(minter);
        for (uint256 i = 0; i < 120; i++) {
            baseToken.mint(owner, i);
        }
        vm.stopPrank();

        // all tokens are locked
        vm.warp(1_720_137_599);
        tRangeUnlocked(0);
        // tokens 0 to 4 are unlocked, others are still locked
        vm.warp(1_720_137_600);
        tRangeUnlocked(5);
        // tokens 0 to 9 are unlocked, others are still locked
        vm.warp(1_721_520_000);
        tRangeUnlocked(10);
        // tokens 0 to 14 are unlocked, others are still locked
        vm.warp(1_722_729_600);
        tRangeUnlocked(15);
        // tokens 0 to 19 are unlocked, others are still locked
        vm.warp(1_724_025_600);
        tRangeUnlocked(20);
        // tokens 0 to 24 are unlocked, others are still locked
        vm.warp(1_725_235_200);
        tRangeUnlocked(25);
        // tokens 0 to 29 are unlocked, others are still locked
        vm.warp(1_726_531_200);
        tRangeUnlocked(30);
        // tokens 0 to 34 are unlocked, others are still locked
        vm.warp(1_727_827_200);
        tRangeUnlocked(35);
        // tokens 0 to 39 are unlocked, others are still locked
        vm.warp(1_729_123_200);
        tRangeUnlocked(40);
        // tokens 0 to 44 are unlocked, others are still locked
        vm.warp(1_730_419_200);
        tRangeUnlocked(45);
        // tokens 0 to 49 are unlocked, others are still locked
        vm.warp(1_731_628_800);
        tRangeUnlocked(50);
        // tokens 0 to 54 are unlocked, others are still locked
        vm.warp(1_732_924_800);
        tRangeUnlocked(55);
        // tokens 0 to 59 are unlocked, others are still locked
        vm.warp(1_734_220_800);
        tRangeUnlocked(60);
        // tokens 0 to 64 are unlocked, others are still locked
        vm.warp(1_735_516_800);
        tRangeUnlocked(65);
        // tokens 0 to 69 are unlocked, others are still locked
        vm.warp(1_736_726_400);
        tRangeUnlocked(70);
        // tokens 0 to 74 are unlocked, others are still locked
        vm.warp(1_738_108_800);
        tRangeUnlocked(75);
        // tokens 0 to 79 are unlocked, others are still locked
        vm.warp(1_739_318_400);
        tRangeUnlocked(80);
        // tokens 0 to 84 are unlocked, others are still locked
        vm.warp(1_740_614_400);
        tRangeUnlocked(85);
        // tokens 0 to 89 are unlocked, others are still locked
        vm.warp(1_741_910_400);
        tRangeUnlocked(90);
        // tokens 0 to 94 are unlocked, others are still locked
        vm.warp(1_743_206_400);
        tRangeUnlocked(95);
        // tokens 0 to 99 are unlocked, others are still locked
        vm.warp(1_744_416_000);
        tRangeUnlocked(100);
        // tokens 0 to 104 are unlocked, others are still locked
        vm.warp(1_745_712_000);
        tRangeUnlocked(105);
        // tokens 0 to 109 are unlocked, others are still locked
        vm.warp(1_747_008_000);
        tRangeUnlocked(110);
    }

    function test_unlock_forAPs() public {
        // most AP tokens are unlocked
        assertTrue(baseToken.isUnlocked(122));
        assertTrue(baseToken.isUnlocked(123));
        assertTrue(baseToken.isUnlocked(124));
        assertTrue(baseToken.isUnlocked(127));
        assertTrue(baseToken.isUnlocked(128));
        assertTrue(baseToken.isUnlocked(129));
        // some AP tokens are locked
        assertFalse(baseToken.isUnlocked(120));
        assertFalse(baseToken.isUnlocked(121));
        assertFalse(baseToken.isUnlocked(125));
        assertFalse(baseToken.isUnlocked(126));
        // AP tokens 125 and 126 are unlocked at specific dates
        vm.warp(1_725_235_200);
        assertTrue(baseToken.isUnlocked(125));
        assertTrue(baseToken.isUnlocked(126));
        // AP tokens 120 and 121 are unlocked at specific dates
        vm.warp(1_736_726_400);
        assertTrue(baseToken.isUnlocked(120));
        assertTrue(baseToken.isUnlocked(121));
    }

    function test_RevertWhen_unlock() public {
        vm.expectRevert(abi.encodeWithSelector(Aside0x02.DisabledFunction.selector));
        baseToken.unlock(_tokenIds());
    }

    function test_isUnlocked_WhenTokenHasBeenUnlockedAndTransfered() public {
        vm.prank(minter);
        baseToken.mint(owner, 0);
        vm.warp(1_720_137_600);
        vm.prank(owner);
        baseToken.transferFrom(owner, recipient, 0);
        assertTrue(baseToken.isUnlocked(0));
    }

    function test_RevertWhen_unlock_ForAlreadyUnlockedToken() public override {}

    function test_RevertWhen_unlock_ForNonexistentToken() public override {}
    // #endregion
}
