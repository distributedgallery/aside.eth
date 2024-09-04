// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {AsideBase, Aside0x04TestHelper} from "./Aside0x04TestHelper.t.sol";

contract Aside0x04Constructor is Aside0x04TestHelper {
    function test_constructor_APTokensAreMinted() public {
        assertEq(token.ownerOf(30), 0x4D3DfD28AA35869D52C5cE077Aa36E3944b48d1C);
        assertEq(token.ownerOf(31), 0x4CD7d2004a323133330D5A62aD7C734fAfD35236);
        for (uint256 i = 32; i <= 35; i++) {
            assertEq(token.ownerOf(i), 0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6);
        }
    }

    function test_constructor_APTokensAreLocked() public {
        // 30
        vm.prank(0x4D3DfD28AA35869D52C5cE077Aa36E3944b48d1C);
        vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenLocked.selector, 30));
        token.transferFrom(0x4D3DfD28AA35869D52C5cE077Aa36E3944b48d1C, recipient, 30);
        // 31
        vm.prank(0x4CD7d2004a323133330D5A62aD7C734fAfD35236);
        vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenLocked.selector, 31));
        token.transferFrom(0x4CD7d2004a323133330D5A62aD7C734fAfD35236, recipient, 31);
        // transfer others out of DG
        for (uint256 i = 32; i <= 35; i++) {
            vm.prank(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6);
            token.transferFrom(0x3c7e48216C74D7818aB1Fd226e56C60C4D659bA6, recipient, i);
        }
        // others are locked thereafter
        for (uint256 i = 32; i <= 35; i++) {
            vm.prank(recipient);
            vm.expectRevert(abi.encodeWithSelector(AsideBase.TokenLocked.selector, i));
            token.transferFrom(recipient, owner, i);
        }
    }
}
